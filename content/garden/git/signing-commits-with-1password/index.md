---
title: "Signing Git Commits With 1Password"
date: 2026-04-16T00:00:00+00:00
description: "Setting up SSH-based git commit signing when 1Password is already running your SSH agent."
garden_topic: "Git"
status: "Seedling"
---

Letting 1Password run your SSH agent is neat! It'll hold holds your keys, and prompts you to authorise each use pretty seamlesly with your password or thumbprint.

For the usecase we'll be talking about here, we can use it to be a git commit signer. For me, this was way easier than the setup I had before: No GPG, no having to add an `ssh-agent` call to your shell's startup prompt, and having to type a password to use a protected key every single time and so on.

This is how it's done...

## Enable the 1Password SSH Agent

Open 1Password's settings:

![1Password menu bar dropdown with the Settings item highlighted](1password-menu-settings.png)

Then look at the Developer section for the SSH Agent setting:

![1Password Settings showing the Developer pane with SSH Agent running](1password-developer-ssh-agent-running.png)

If it says `running` next to `SSH Agent`, you're golden!

## Agent Configuration With `SSH_AUTH_SOCK`

Then, we want to make sure our tools and apps can actually find the 1Password agent. The trick is exporting `SSH_AUTH_SOCK` globally.

1Password's docs have a [LaunchAgent plist](https://developer.1password.com/docs/ssh/agent/compatibility/#configure-ssh_auth_sock-globally-for-every-client) that does this on boot:

```bash
mkdir -p ~/Library/LaunchAgents
cat << EOF > ~/Library/LaunchAgents/com.1password.SSH_AUTH_SOCK.plist
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>com.1password.SSH_AUTH_SOCK</string>
  <key>ProgramArguments</key>
  <array>
    <string>/bin/sh</string>
    <string>-c</string>
    <string>/bin/ln -sf \$HOME/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock \$SSH_AUTH_SOCK</string>
  </array>
  <key>RunAtLoad</key>
  <true/>
</dict>
</plist>
EOF
launchctl load -w ~/Library/LaunchAgents/com.1password.SSH_AUTH_SOCK.plist
```

## Get (or Create) an SSH Key

You probably already have one at `~/.ssh/id_ed25519.pub`. If you don't, `ssh-keygen -t ed25519` will sort you out.

Grab the pubkey and [add a new signing key on GitHub](https://github.com/settings/ssh/new).

Important bit: click the **Key Type** dropdown and pick `Signing Key`, not `Authentication Key`:

![GitHub new SSH key form with the Key type dropdown open and Signing Key selected](github-key-type-signing-key.png)

(It's the same key material, different role here)

## `.gitconfig` Setup

Drop this into `~/.gitconfig`:

```ini
[user]
    email = <your email>
    name = <your name>
    signingkey = <your ssh public key from the last step>
[commit]
    gpgsign = true
[tag]
    forceSignAnnotated = true
    gpgsign = true
[gpg]
    format = ssh
```

For the email, I've switched to using [the Github `noreply` option](https://docs.github.com/en/account-and-profile/reference/email-addresses-reference#your-noreply-email-address). For me that's `petems@users.noreply.github.com`, but they've recently added an option to hide your email address completely as well:

![GitHub email settings with the Keep my email addresses private toggle turned on](github-keep-email-private.png)

Push a test commit somewhere and check for the little `Verified` badge next to it on GitHub:

![GitHub commit header showing a green Verified badge next to petems and claude](github-commit-verified-badge.png)

Boom, done!

## Troubleshooting

If it doesn't seem to be signing, run:

```bash
git log --show-signature -1
```

If you get `error: gpg.ssh.allowedSignersFile needs to be configured and exist for ssh signature verification`, create `~/.config/git/allowed_signers` with a line like:

```text
your-email ssh-public-key-name ssh-public-key
```

Then tell git about it:

```bash
git config --global gpg.ssh.allowedSignersFile ~/.config/git/allowed_signers
```

That should fit it!

## References

### GitHub Docs

* [Signing commits](https://docs.github.com/en/authentication/managing-commit-signature-verification/signing-commits)
* [About commit signature verification](https://docs.github.com/en/authentication/managing-commit-signature-verification/about-commit-signature-verification)

### 1Password

* [Sign Git commits with SSH (1Password Developer docs)](https://developer.1password.com/docs/ssh/git-commit-signing/)
* [Sign your Git commits with 1Password (1Password blog, Sep 2022)](https://1password.com/blog/git-commit-signing)

### Why Sign at All

* [Signing Git Commits With Your SSH Key, Caleb Hearth](https://calebhearth.com/sign-git-with-ssh)
