#!/usr/bin/env python3
"""
Pack Validation Script for Golden Moments Memory Game

This script validates the pack index JSON file and checks for common issues.
Usage: python scripts/validate_packs.py
"""

import json
import sys
from datetime import datetime
from pathlib import Path

try:
    import requests
    HAS_REQUESTS = True
except ImportError:
    HAS_REQUESTS = False

def validate_json_syntax(file_path):
    """Validate JSON syntax."""
    try:
        with open(file_path, 'r') as f:
            data = json.load(f)
        print("✅ JSON syntax is valid")
        return data
    except json.JSONDecodeError as e:
        print(f"❌ JSON syntax error: {e}")
        return None
    except FileNotFoundError:
        print(f"❌ File not found: {file_path}")
        return None

def validate_pack_structure(pack):
    """Validate individual pack structure."""
    required_fields = [
        'id', 'title', 'description', 'theme', 'category', 
        'difficulty', 'isPremium', 'isFeatured', 'imageCount',
        'estimatedSize', 'version', 'createdAt', 'updatedAt',
        'tags', 'images'
    ]
    
    issues = []
    
    # Check required fields
    for field in required_fields:
        if field not in pack:
            issues.append(f"Missing required field: {field}")
    
    # Validate difficulty
    if 'difficulty' in pack:
        valid_difficulties = ['easy', 'medium', 'hard', 'brainy']
        if pack['difficulty'] not in valid_difficulties:
            issues.append(f"Invalid difficulty: {pack['difficulty']}")
    
    # Validate image count matches actual images
    if 'imageCount' in pack and 'images' in pack:
        if pack['imageCount'] != len(pack['images']):
            issues.append(f"imageCount ({pack['imageCount']}) doesn't match actual images ({len(pack['images'])})")
    
    # Validate image structure
    if 'images' in pack:
        for i, image in enumerate(pack['images']):
            if 'id' not in image:
                issues.append(f"Image {i} missing 'id' field")
            if 'url' not in image:
                issues.append(f"Image {i} missing 'url' field")
            if 'caption' not in image:
                issues.append(f"Image {i} missing 'caption' field")
    
    return issues

def validate_categories(data):
    """Validate category consistency."""
    issues = []
    
    if 'categories' not in data or 'packs' not in data:
        return ["Missing categories or packs data"]
    
    # Get all category IDs
    category_ids = {cat['id'] for cat in data['categories']}
    
    # Check pack categories
    for pack in data['packs']:
        if 'category' in pack and pack['category'] not in category_ids:
            issues.append(f"Pack '{pack.get('id', 'unknown')}' references unknown category: {pack['category']}")
    
    # Validate category pack counts
    for category in data['categories']:
        cat_id = category['id']
        actual_count = sum(1 for pack in data['packs'] if pack.get('category') == cat_id)
        declared_count = category.get('packCount', 0)
        
        if actual_count != declared_count:
            issues.append(f"Category '{cat_id}' declares {declared_count} packs but has {actual_count}")
    
    return issues

def validate_featured_packs(data):
    """Validate featured packs consistency."""
    issues = []
    
    if 'featuredPacks' not in data or 'packs' not in data:
        return ["Missing featuredPacks or packs data"]
    
    pack_ids = {pack['id'] for pack in data['packs']}
    
    # Check featured pack IDs exist
    for featured_id in data['featuredPacks']:
        if featured_id not in pack_ids:
            issues.append(f"Featured pack ID '{featured_id}' not found in packs")
    
    # Check isFeatured consistency
    featured_from_list = set(data['featuredPacks'])
    featured_from_flags = {pack['id'] for pack in data['packs'] if pack.get('isFeatured', False)}
    
    if featured_from_list != featured_from_flags:
        issues.append("Mismatch between featuredPacks list and isFeatured flags")
    
    return issues

def check_image_urls(data, check_accessibility=False):
    """Check image URL format and optionally accessibility."""
    issues = []

    if not check_accessibility:
        print("ℹ️  Skipping URL accessibility check (use --check-urls to enable)")
        return issues

    if not HAS_REQUESTS:
        issues.append("requests module not available - cannot check URL accessibility")
        print("⚠️  Install requests module to check URL accessibility: pip install requests")
        return issues

    print("🔍 Checking image URL accessibility...")

    for pack in data.get('packs', []):
        pack_id = pack.get('id', 'unknown')

        # Check thumbnail
        if 'thumbnailUrl' in pack:
            if not check_url_accessible(pack['thumbnailUrl']):
                issues.append(f"Pack '{pack_id}' thumbnail URL not accessible")

        # Check preview images
        for i, url in enumerate(pack.get('previewImages', [])):
            if not check_url_accessible(url):
                issues.append(f"Pack '{pack_id}' preview image {i} not accessible")

        # Check game images
        for image in pack.get('images', []):
            if not check_url_accessible(image.get('url', '')):
                issues.append(f"Pack '{pack_id}' image '{image.get('id', 'unknown')}' not accessible")

    return issues

def check_url_accessible(url):
    """Check if URL is accessible."""
    if not HAS_REQUESTS:
        return False

    try:
        response = requests.head(url, timeout=5)
        return response.status_code == 200
    except:
        return False

def validate_metadata(data):
    """Validate top-level metadata."""
    issues = []
    
    # Check total packs count
    if 'totalPacks' in data and 'packs' in data:
        declared_total = data['totalPacks']
        actual_total = len(data['packs'])
        
        if declared_total != actual_total:
            issues.append(f"totalPacks ({declared_total}) doesn't match actual pack count ({actual_total})")
    
    # Check lastUpdated format
    if 'lastUpdated' in data:
        try:
            datetime.fromisoformat(data['lastUpdated'].replace('Z', '+00:00'))
        except ValueError:
            issues.append("lastUpdated is not in valid ISO format")
    
    return issues

def main():
    """Main validation function."""
    import argparse
    
    parser = argparse.ArgumentParser(description='Validate Golden Moments pack data')
    parser.add_argument('--check-urls', action='store_true', 
                       help='Check image URL accessibility (slow)')
    parser.add_argument('--file', default='assets/data/packs_index.json',
                       help='Path to pack index file')
    
    args = parser.parse_args()
    
    print("🔍 Validating Golden Moments pack data...")
    print(f"📁 File: {args.file}")
    print()
    
    # Load and validate JSON
    data = validate_json_syntax(args.file)
    if not data:
        sys.exit(1)
    
    all_issues = []
    
    # Validate metadata
    print("📊 Validating metadata...")
    metadata_issues = validate_metadata(data)
    all_issues.extend(metadata_issues)
    
    # Validate categories
    print("📂 Validating categories...")
    category_issues = validate_categories(data)
    all_issues.extend(category_issues)
    
    # Validate featured packs
    print("⭐ Validating featured packs...")
    featured_issues = validate_featured_packs(data)
    all_issues.extend(featured_issues)
    
    # Validate individual packs
    print("📦 Validating individual packs...")
    for pack in data.get('packs', []):
        pack_issues = validate_pack_structure(pack)
        for issue in pack_issues:
            all_issues.append(f"Pack '{pack.get('id', 'unknown')}': {issue}")
    
    # Check image URLs if requested
    if args.check_urls:
        url_issues = check_image_urls(data, check_accessibility=True)
        all_issues.extend(url_issues)
    
    # Report results
    print()
    if all_issues:
        print(f"❌ Found {len(all_issues)} issues:")
        for issue in all_issues:
            print(f"   • {issue}")
        sys.exit(1)
    else:
        print("✅ All validations passed!")
        print(f"📊 Summary: {len(data.get('packs', []))} packs, {len(data.get('categories', []))} categories")

if __name__ == '__main__':
    main()
