// Package main provides a simple Cloudflare DDNS client
package main

import (
	"bytes"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"log/slog"
	"net/http"
	"os"
	"strings"
	"sync"
	"time"
)

// RecordConfig holds the configuration for each DNS record
type RecordConfig struct {
	APIToken string `json:"api_token"`
	ZoneID   string `json:"zone_id"`
	RecordID string `json:"record_id"`
	Domain   string `json:"domain_name"`
}

// DNSUpdateRequest represents the Cloudflare API request
type DNSUpdateRequest struct {
	Type    string `json:"type"`
	Name    string `json:"name"`
	Content string `json:"content"`
	TTL     int    `json:"ttl"`
}

// CloudflareResponse represents the API response structure
type CloudflareResponse struct {
	Success bool              `json:"success"`
	Errors  []CloudflareError `json:"errors,omitempty"`
}

// CloudflareError represents an error in the API response
type CloudflareError struct {
	Code    int    `json:"code"`
	Message string `json:"message"`
}

const cacheFilePath = "/var/tmp/tinycfddns_ip_cache.txt"

var httpClient = &http.Client{Timeout: 10 * time.Second}

func getCurrentIP() (string, error) {
	resp, err := httpClient.Get("https://api.ipify.org")
	if err != nil {
		return "", fmt.Errorf("failed to request IP: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return "", fmt.Errorf("IP service returned status code %d", resp.StatusCode)
	}

	ipBytes, err := io.ReadAll(resp.Body)
	if err != nil {
		return "", fmt.Errorf("failed to read IP response: %w", err)
	}

	return strings.TrimSpace(string(ipBytes)), nil
}

func updateDNSRecord(config *RecordConfig, ip string) error {
	url := fmt.Sprintf("https://api.cloudflare.com/client/v4/zones/%s/dns_records/%s",
		config.ZoneID, config.RecordID)

	updateReq := DNSUpdateRequest{
		Type:    "A",
		Name:    config.Domain,
		Content: ip,
		TTL:     1,
	}

	jsonData, err := json.Marshal(updateReq)
	if err != nil {
		return fmt.Errorf("failed to marshal JSON: %w", err)
	}

	req, err := http.NewRequest("PUT", url, bytes.NewBuffer(jsonData))
	if err != nil {
		return fmt.Errorf("failed to create request: %w", err)
	}

	req.Header.Set("Authorization", "Bearer "+config.APIToken)
	req.Header.Set("Content-Type", "application/json")

	resp, err := httpClient.Do(req)
	if err != nil {
		return fmt.Errorf("request failed: %w", err)
	}
	defer resp.Body.Close()

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return fmt.Errorf("failed to read response body: %w", err)
	}

	if resp.StatusCode >= 400 {
		var cfResp CloudflareResponse
		if err := json.Unmarshal(body, &cfResp); err == nil && len(cfResp.Errors) > 0 {
			return fmt.Errorf("API error: %s (code: %d)", cfResp.Errors[0].Message, cfResp.Errors[0].Code)
		}
		return fmt.Errorf("API error: %d %s", resp.StatusCode, string(body))
	}

	return nil
}

func loadCachedIP() (string, error) {
	data, err := os.ReadFile(cacheFilePath)
	if err != nil {
		if errors.Is(err, os.ErrNotExist) {
			return "", nil
		}
		return "", err
	}

	return strings.TrimSpace(string(data)), nil
}

func saveCachedIP(ip string) error {
	return os.WriteFile(cacheFilePath, []byte(ip), 0644)
}

func main() {
	logger := slog.New(slog.NewJSONHandler(os.Stdout, nil))
	slog.SetDefault(logger)

	slog.Debug("Getting value of CONFIG_PATH environment variable")
	configPath := os.Getenv("CONFIG_PATH")
	if configPath == "" {
		slog.Error("CONFIG_PATH environment variable not set")
		os.Exit(1)
	}

	slog.Debug("Reading CONFIG_PATH value", "path", configPath)
	configFile, err := os.ReadFile(configPath)
	if err != nil {
		slog.Error("Failed to read config file", "error", err, "path", configPath)
		os.Exit(1)
	}

	slog.Info("Parsing config file", "path", configPath)
	var configs []RecordConfig
	if err := json.Unmarshal(configFile, &configs); err != nil {
		slog.Error("Failed to parse config", "error", err)
		os.Exit(1)
	}

	if len(configs) == 0 {
		slog.Error("No DNS records found in configuration")
		os.Exit(1)
	}

	for i, config := range configs {
		if config.APIToken == "" || config.ZoneID == "" || config.RecordID == "" || config.Domain == "" {
			slog.Error("Missing required configuration fields", "index", i)
			os.Exit(1)
		}
	}

	slog.Info("Fetching current IP address")
	currentIP, err := getCurrentIP()
	if err != nil {
		slog.Error("Error getting current IP address", "error", err)
		os.Exit(1)
	}

	slog.Info("Successfully fetched IP address", "ip", currentIP)

	slog.Info("Loading current cached IP address")
	cachedIP, err := loadCachedIP()
	if err != nil {
		slog.Warn("Could not load cached IP, will update DNS records", "error", err)
		cachedIP = ""
	}

	if currentIP == cachedIP {
		slog.Info("Current IP address matches cached IP address, no update needed", "ip", currentIP)
		os.Exit(0)
	}

	slog.Info("IP has changed, updating DNS records",
		"previous_ip", cachedIP,
		"new_ip", currentIP,
		"record_count", len(configs))

	var wg sync.WaitGroup
	var updateErrors int
	var mu sync.Mutex

	for i, config := range configs {
		wg.Add(1)
		go func(idx int, cfg RecordConfig) {
			defer wg.Done()

			slog.Info("Updating DNS record",
				"index", idx,
				"domain", cfg.Domain)

			if err := updateDNSRecord(&cfg, currentIP); err != nil {
				slog.Error("Error updating DNS record",
					"index", idx,
					"domain", cfg.Domain,
					"error", err)

				mu.Lock()
				updateErrors++
				mu.Unlock()
			} else {
				slog.Info("Successfully updated DNS record",
					"index", idx,
					"domain", cfg.Domain)
			}
		}(i, config)
	}

	wg.Wait()

	if updateErrors > 0 {
		slog.Error("Failed to update some DNS records", "error_count", updateErrors)
	} else {
		if err := saveCachedIP(currentIP); err != nil {
			slog.Warn("Failed to save IP address to cache", "error", err)
		} else {
			slog.Info("Saved IP address to cache")
		}

		slog.Info("Successfully updated all DNS records", "record_count", len(configs))
	}
}
