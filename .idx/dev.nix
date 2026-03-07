# To learn more about how to use Nix to configure your environment
# see: https://developers.google.com/idx/guides/customize-idx-env
{ pkgs, ... }: {
  # Which nixpkgs channel to use.
  channel = "stable-24.05"; # or "unstable"
  # Use https://search.nixos.org/packages to find packages
  packages = [
    pkgs.go
    pkgs.python311
    pkgs.python311Packages.pip
    pkgs.nodejs_20
    pkgs.nodePackages.nodemon
    pkgs.google-cloud-sdk # Added for GCP interaction
    pkgs.nano
  ];
  # Sets environment variables in the workspace
  env = {
    # Set the GCP project ID
    GCP_PROJECT = "i-dub-thee";
  };
idx = {
    # Search for the extensions you want on Open VSX and list them here
    extensions = [
      "rangav.vscode-thunder-client" # useful for testing API calls if needed
      "googlecloudtools.cloudcode" # VS Code extension for GCP
    ];

    workspace = {
      # AUTOMATED SETUP HOOKS (Zero Omission)
      onCreate = {
        # Runs when you first create the workspace
        npm-install = "npm install";
        
        # Initial compilation check
        compile-check = "npm run build";
        
        # Configure gcloud with the project ID
        gcloud-init = "gcloud config set project i-dub-thee";
      };
onStart = {
        # Runs every time the workspace resumes
        # We ensure environment is clean
        echo-status = "echo 'IDX Environment Ready for GCP project i-dub-thee.'";
      };
    };
  };
}
