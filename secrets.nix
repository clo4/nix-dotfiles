let
  system-homeserver1 = builtins.readFile ./hosts/homeserver1/id_ed25519.pub;
  robert-macmini = builtins.readFile ./hosts/macmini/users/robert/id_ed25519.pub;
  robert-macbook-air = builtins.readFile ./hosts/macbook-air/users/robert/id_ed25519.pub;
  robert = [
    robert-macmini
    robert-macbook-air
  ];
in
{
  "hosts/homeserver1/tailscale-homeserver1.age".publicKeys = [ system-homeserver1 ] ++ robert;
  "hosts/homeserver1/tinycfddnsclient-config.age".publicKeys = [ system-homeserver1 ] ++ robert;
}
