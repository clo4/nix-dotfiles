package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"log/slog"
	"net/http"
	"os"
	"path/filepath"
	"strings"
	"sync"
	"time"
)

// DNSRecord represents a DNS record to update
type DNSRecord struct {
	// Name is the "host" name for the record, fully qualified.
	Name string `json:"name"`
	// APIToken is the token used to make the request to the Cloudflare API.
	// Specifying this per-record allows for different tokens to be used for different records.
	APIToken string `json:"api_token"`
	// ZoneID is the "zone ID", which is the ID for the configuration for a given domain name.
	ZoneID string `json:"zone_id"`
	// RecordID is the ID for the DNS record to update. This is only exposed through the API.
	RecordID string `json:"record_id"`
}

// DNSConfiguration holds separate lists of A and AAAA records
type DNSConfiguration struct {
	A    []DNSRecord `json:"a,omitempty"`
	AAAA []DNSRecord `json:"aaaa,omitempty"`
}

func loadDNSConfiguration() (DNSConfiguration, error) {
	var configuration DNSConfiguration

	configPath := os.Getenv("DDNS_CONFIG_PATH")
	if configPath == "" {
		return configuration, fmt.Errorf("DDNS_CONFIG_PATH environment variable not set")
	}

	configFile, err := os.ReadFile(configPath)
	if err != nil {
		return configuration, fmt.Errorf("failed to read config file: %w", err)
	}

	err = json.Unmarshal(configFile, &configuration)
	if err != nil {
		return configuration, fmt.Errorf("failed to parse config file: %w", err)
	}

	if len(configuration.A) == 0 && len(configuration.AAAA) == 0 {
		return configuration, fmt.Errorf("no DNS records found in config file")
	}

	return configuration, nil
}

func getCachePath() string {
	return os.Getenv("DDNS_CACHE_PATH")
}

// CloudflareUpdateRequest represents the Cloudflare API request
type CloudflareUpdateRequest struct {
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

func updateCloudflareRecord(client *http.Client, record *DNSRecord, recordType string, address string) error {
	url := "https://api.cloudflare.com/client/v4/zones/" + record.ZoneID + "/dns_records/" + record.RecordID

	updateReq := CloudflareUpdateRequest{
		Type:    recordType,
		Name:    record.Name,
		Content: address,
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

	req.Header.Set("Authorization", "Bearer "+record.APIToken)
	req.Header.Set("Content-Type", "application/json")

	resp, err := client.Do(req)
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

func loadCachedIP(basePath, fileName string) (string, error) {
	if basePath == "" {
		// Reading from a non-existent cache is not an error, it should
		// return nothing because there was nothing to read.
		return "", nil
	}

	cachePath := filepath.Join(basePath, fileName)
	data, err := os.ReadFile(cachePath)
	if err != nil {
		if os.IsNotExist(err) {
			return "", nil // File doesn't exist yet, not an error
		}
		return "", fmt.Errorf("failed to read cache file: %w", err)
	}

	return strings.TrimSpace(string(data)), nil
}

func saveCachedIP(basePath, fileName, content string) error {
	// Writing to a non-existent cache is an error.
	if basePath == "" {
		return fmt.Errorf("cannot write cache file, no base path provided")
	}

	cachePath := filepath.Join(basePath, fileName)
	err := os.WriteFile(cachePath, []byte(content), 0644)
	if err != nil {
		return fmt.Errorf("failed to write cache file: %w", err)
	}

	return nil
}

func fetchCurrentIP(client *http.Client, api string) (string, error) {
	resp, err := client.Get(api)
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

// DNSUpdateConfig is the data passed to updateDNS
type DNSUpdateConfig struct {
	// logger is the structured logger to use for logging.
	logger *slog.Logger
	// client is the HTTP client to use for making requests.
	client *http.Client
	// records is a slice of DNSRecord structs representing the DNS records to update.
	// All records in this slice will be updated using this configuration.
	records []DNSRecord
	// recordType is the "type" field in the Cloudflare DNS update API request.
	// This is expected to be "A" or "AAAA".
	recordType string
	// baseCachePath is the directory where cache files are stored.
	// If this is an empty string, cache files will not be used,
	// which means that the DNS records will be updated every time, even
	// if the IP address has not changed from the last run.
	baseCachePath string
	// cacheFileName is the file name used to store the cached IP address.
	cacheFileName string
	// ipAPIURL is the URL to use for fetching the current IP address.
	// It is expected to return a plain string containing only an IP address.
	// It does not matter which form of address it returns.
	ipAPIURL string
}

func updateDNS(config DNSUpdateConfig) {
	logger := config.logger

	// 1. Get the IP address using the config
	currentIP, err := fetchCurrentIP(config.client, config.ipAPIURL)
	if err != nil {
		logger.Error("Failed to get current IP address", "error", err)
		return
	}

	// 2. Read cached IP address
	// If there is no baseCachePath, loadCachedIP will return an empty string
	// and no error. A valid IP address can never be an empty string, so this
	// is valid for comparison.
	cachedIP, err := loadCachedIP(config.baseCachePath, config.cacheFileName)
	if err != nil {
		logger.Warn("Failed to read cached IP", "error", err)
		// Continue as if the cached IP is ""
	}

	// 3. If cached IP address matches current IP address, skip update
	if cachedIP == currentIP {
		logger.Info("IP address unchanged, skipping update", "ip", currentIP)
		return
	}

	logger.Info("IP address changed, updating DNS records",
		"old_ip", cachedIP,
		"new_ip", currentIP,
		"record_type", config.recordType,
		"record_count", len(config.records))

	// 4. Update DNS records concurrently
	var wg sync.WaitGroup

	// Instead of using a channel, we use a slice with one element per goroutine.
	// If there's an error, that element will be set to true. Pretty cheap way to
	// indicate success/failure without synchronisation.
	// (This is safe according to the Go memory model.)
	updateErrors := make([]bool, len(config.records))

	for i := range config.records {
		wg.Add(1)
		go func(index int) {
			defer wg.Done()
			record := &config.records[index]
			err := updateCloudflareRecord(
				config.client,
				record,
				config.recordType,
				currentIP)

			if err != nil {
				updateErrors[index] = true
				logger.Error("Failed to update DNS record",
					"name", record.Name,
					"error", err)
			} else {
				logger.Info("Successfully updated DNS record",
					"name", record.Name,
					"ip", currentIP)
			}
		}(i)
	}

	wg.Wait()

	// 5. If there were no failures, write the new IP address to the cache file
	updateFailed := false
	for _, err := range updateErrors {
		if err {
			updateFailed = true
			break
		}
	}

	if config.baseCachePath == "" {
		logger.Info("Not caching IP address because there is no DDNS_CACHE_PATH set", "ip", currentIP)
	} else if updateFailed {
		logger.Warn("Not caching IP address due to update errors", "ip", currentIP)
	} else {
		err = saveCachedIP(config.baseCachePath, config.cacheFileName, currentIP)
		if err != nil {
			logger.Warn("Failed to save cached IP", "error", err)
		} else {
			logger.Info("Successfully cached new IP address", "ip", currentIP)
		}
	}
}

func run(logger *slog.Logger) error {
	logger.Info("Starting DDNS client")

	baseCachePath := getCachePath()
	logger.Info("Cache path", "path", baseCachePath)

	configuration, err := loadDNSConfiguration()
	if err != nil {
		return fmt.Errorf("failed to load configuration: %w", err)
	}
	logger.Info("Loaded configuration")

	client := &http.Client{Timeout: 10 * time.Second}

	var wg sync.WaitGroup
	a_records := len(configuration.A)
	aaaa_records := len(configuration.AAAA)
	if a_records > 0 {
		logger.Info("Updating A records", "count", a_records)
		wg.Add(1)
		go func() {
			defer wg.Done()
			updateDNS(DNSUpdateConfig{
				logger:        logger.With("record_type", "A"),
				client:        client,
				records:       configuration.A,
				recordType:    "A",
				baseCachePath: baseCachePath,
				cacheFileName: "current_address_ipv4.txt",
				ipAPIURL:      "https://api.ipify.org",
			})
		}()
	}
	if aaaa_records > 0 {
		logger.Info("Updating AAAA records", "count", aaaa_records)
		wg.Add(1)
		go func() {
			defer wg.Done()
			updateDNS(DNSUpdateConfig{
				logger:        logger.With("record_type", "AAAA"),
				client:        client,
				records:       configuration.AAAA,
				recordType:    "AAAA",
				baseCachePath: baseCachePath,
				cacheFileName: "current_address_ipv6.txt",
				ipAPIURL:      "https://api6.ipify.org",
			})
		}()
	}
	wg.Wait()

	logger.Info("DDNS client finished")
	return nil
}

func main() {
	logger := slog.New(slog.NewJSONHandler(os.Stderr, nil))

	if err := run(logger); err != nil {
		logger.Error("Application failed", "error", err)
		os.Exit(1)
	}
}
