#!/bin/bash
aws cloudfront create-invalidation --distribution-id <ID> --paths '/*'