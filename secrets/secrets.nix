# Agenix recipient configuration.
# Each secret maps to the set of public keys that can decrypt it.
# Add new secrets here, then run:
#   nix run github:ryantm/agenix -- -e secrets/my-secret.age
# to create/edit the encrypted file.

let
  host = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGDWgK5TxFG/t4Er8t73aC/TVqeQ1XWfEauJ2n1X7EDm root@jat-fwk-nix";
  user = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJRcyHK7d/yfYTS6rEAxD2LFmIKQO3FxVfmDvc8RRelg 44571350+j4t1nd3r@users.noreply.github.com";
  all  = [ host user ];
in
{
  # "example.age".publicKeys = all;
}
