#!/bin/bash
aws ecr get-login-password | docker login --username AWS --password-stdin <ECR-URL>