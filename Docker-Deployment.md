# Docker Deployment Overview

`hroot` supports two distinct Docker deployment methods depending on your laboratory's needs:

1. **[Docker (precompiled)](Docker-(precompiled).md) (Standard & Recommended)**:  
   Pulls pre-built container images from `ghcr.io`. Features instant zero-touch startup, automatic secret generation, and full configuration via the Web Setup Wizard at `/setup`. Best for standard production environments.

2. **[Docker (self-compiled)](Docker-(self-compiled).md) (Build from Source)**:  
   Compiles Docker images locally from the source code and `Dockerfile`. Best for laboratories making custom code modifications, styling changes, local development, or headless Ansible provisioning.

3. **[Docker Multi-Instance Setup](Docker-Multi-Instance-Setup.md)**:  
   Comprehensive architecture and step-by-step instructions for hosting multiple independent laboratories or staging/production instances on a single host via a shared reverse proxy.
