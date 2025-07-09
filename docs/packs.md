# Pack Management Guide

This guide explains how to update pack data and image links in the Golden Moments memory game.

## Overview

The Golden Moments app uses a local JSON-based pack management system with long-term image caching. All pack metadata is stored locally in `assets/data/packs_index.json`, while images are cached for 1 year after first download.

## Pack Data Structure

### Main Index File: `assets/data/packs_index.json`

```json
{
  "version": "1.0.0",
  "lastUpdated": "2025-01-09T12:00:00Z",
  "totalPacks": 12,
  "categories": [...],
  "featuredPacks": ["pack_id_1", "pack_id_2"],
  "packs": [...]
}
```

### Pack Object Structure

```json
{
  "id": "unique_pack_identifier",
  "title": "Human-readable pack name",
  "description": "Pack description for users",
  "theme": "Pack theme/topic",
  "category": "category_id",
  "difficulty": "easy|medium|hard|brainy",
  "isPremium": false,
  "isFeatured": true,
  "imageCount": 8,
  "estimatedSize": "2.1 MB",
  "version": "1.0.0",
  "createdAt": "2025-01-01T00:00:00Z",
  "updatedAt": "2025-01-01T00:00:00Z",
  "tags": ["tag1", "tag2"],
  "thumbnailUrl": "https://example.com/thumbnail.jpg",
  "previewImages": [
    "https://example.com/preview1.jpg",
    "https://example.com/preview2.jpg"
  ],
  "images": [
    {
      "id": "unique_image_id",
      "url": "https://example.com/image.jpg",
      "caption": "Image description"
    }
  ]
}
```

### Category Object Structure

```json
{
  "id": "category_identifier",
  "name": "Category Display Name",
  "description": "Category description",
  "iconUrl": "https://example.com/icon.jpg",
  "packCount": 5
}
```

## Adding New Packs

### Step 1: Prepare Images

1. **Image Requirements:**
   - Format: JPG or PNG
   - Size: 400x400px recommended for game tiles
   - Quality: High resolution for seniors with vision needs
   - Accessibility: High contrast, clear subjects

2. **Upload Images:**
   - Use a reliable CDN (Unsplash, Cloudinary, etc.)
   - Ensure URLs are HTTPS and permanent
   - Test image accessibility and loading speed

### Step 2: Update Pack Index

1. **Open** `assets/data/packs_index.json`

2. **Update Metadata:**
   ```json
   {
     "totalPacks": 13,  // Increment count
     "lastUpdated": "2025-01-09T15:30:00Z"  // Current timestamp
   }
   ```

3. **Add Pack Object:**
   ```json
   {
     "id": "new_pack_animals_safari",
     "title": "Safari Animals",
     "description": "Majestic animals from African safaris",
     "theme": "Wildlife",
     "category": "animals",
     "difficulty": "medium",
     "isPremium": false,
     "isFeatured": false,
     "imageCount": 6,
     "estimatedSize": "3.2 MB",
     "version": "1.0.0",
     "createdAt": "2025-01-09T15:30:00Z",
     "updatedAt": "2025-01-09T15:30:00Z",
     "tags": ["safari", "animals", "wildlife", "africa"],
     "thumbnailUrl": "https://images.unsplash.com/photo-safari-thumb",
     "previewImages": [
       "https://images.unsplash.com/photo-safari-preview1",
       "https://images.unsplash.com/photo-safari-preview2"
     ],
     "images": [
       {
         "id": "lion_1",
         "url": "https://images.unsplash.com/photo-lion",
         "caption": "Majestic Lion"
       },
       {
         "id": "elephant_1", 
         "url": "https://images.unsplash.com/photo-elephant",
         "caption": "African Elephant"
       }
     ]
   }
   ```

4. **Update Category Count:**
   ```json
   {
     "id": "animals",
     "name": "Animals",
     "packCount": 4  // Increment if adding to existing category
   }
   ```

## Updating Existing Packs

### Modifying Pack Content

1. **Find the pack** in `packs` array by `id`
2. **Update fields** as needed:
   - `updatedAt`: Always update to current timestamp
   - `version`: Increment if significant changes
   - `imageCount`: Update if adding/removing images
   - `estimatedSize`: Recalculate if images changed

### Adding Images to Existing Pack

```json
{
  "images": [
    // ... existing images ...
    {
      "id": "new_image_id",
      "url": "https://example.com/new-image.jpg", 
      "caption": "New Image Description"
    }
  ]
}
```

### Updating Image URLs

If image URLs change (CDN migration, etc.):

1. **Update URLs** in pack objects
2. **Clear image cache** (optional - cache will auto-update)
3. **Test image loading** in development

## Image URL Best Practices

### Recommended Image Sources

1. **Unsplash** (Free, high-quality)
   ```
   https://images.unsplash.com/photo-[id]?w=400&h=400&fit=crop
   ```

2. **Cloudinary** (Optimized delivery)
   ```
   https://res.cloudinary.com/[cloud]/image/upload/w_400,h_400,c_fill/[id]
   ```

3. **Custom CDN** (Your own hosting)
   ```
   https://cdn.yourdomain.com/images/[pack]/[image].jpg
   ```

### URL Parameters for Optimization

- `w=400&h=400` - Resize to 400x400px
- `fit=crop` - Crop to maintain aspect ratio
- `q=80` - Set quality to 80% (balance size/quality)
- `auto=format` - Auto-select best format (WebP, etc.)

### Senior-Friendly Image Guidelines

1. **High Contrast:** Clear distinction between subjects and backgrounds
2. **Simple Subjects:** Avoid cluttered or complex images
3. **Familiar Objects:** Use recognizable, nostalgic items
4. **Large Details:** Avoid images with tiny details
5. **Bright Colors:** Use vibrant, cheerful imagery

## Testing Pack Updates

### Development Testing

1. **Hot Reload:** Changes to JSON require app restart
   ```bash
   flutter hot restart
   ```

2. **Verify Pack Loading:**
   - Check pack appears in discovery
   - Test pack details page
   - Verify image loading

3. **Test Image Caching:**
   - Images should load quickly after first view
   - Check cache statistics in debug mode

### Production Deployment

1. **Validate JSON:** Ensure valid JSON syntax
   ```bash
   cat assets/data/packs_index.json | jq .
   ```

2. **Test Image URLs:** Verify all URLs are accessible
   ```bash
   curl -I "https://example.com/image.jpg"
   ```

3. **Build and Test:**
   ```bash
   flutter build web
   flutter build apk
   ```

## Cache Management

### Image Cache Behavior

- **Cache Duration:** 1 year (365 days)
- **Storage Location:** App documents directory
- **Auto Cleanup:** Expired images removed automatically
- **Cache Key:** SHA-256 hash of image URL

### Manual Cache Operations

```dart
// Clear all cached images (development only)
await LongTermImageCache.instance.clearAllCache();

// Clean expired cache entries
await LongTermImageCache.instance.cleanExpiredCache();

// Get cache statistics
final stats = await LongTermImageCache.instance.getCacheStatistics();
```

## Troubleshooting

### Common Issues

1. **Pack Not Appearing:**
   - Check JSON syntax validity
   - Verify pack ID is unique
   - Ensure category exists
   - Restart app after JSON changes

2. **Images Not Loading:**
   - Verify image URLs are accessible
   - Check HTTPS requirement
   - Test image URLs in browser
   - Clear cache if URLs changed

3. **Performance Issues:**
   - Optimize image sizes (400x400px max)
   - Use CDN with compression
   - Limit pack size (8-12 images max)
   - Monitor cache statistics

### Debug Commands

```bash
# Validate JSON syntax
jq . assets/data/packs_index.json

# Test image URL accessibility
curl -I "https://example.com/image.jpg"

# Check app logs for errors
flutter logs
```

## Version Control

### Best Practices

1. **Commit Strategy:**
   - Separate commits for pack data vs code changes
   - Include pack count in commit messages
   - Tag releases with version numbers

2. **Backup Strategy:**
   - Keep backup of `packs_index.json`
   - Document image URL sources
   - Track pack performance metrics

3. **Release Process:**
   ```bash
   git add assets/data/packs_index.json
   git commit -m "feat: add safari animals pack (13 total packs)"
   git tag v1.1.0
   ```

## Performance Considerations

### Pack Size Guidelines

- **Easy Difficulty:** 6-8 images (3x4 grid)
- **Medium Difficulty:** 8-12 images (4x4 grid)  
- **Hard Difficulty:** 12-20 images (5x5 grid)
- **Brainy Difficulty:** 20-36 images (6x6 grid)

### Image Optimization

- **File Size:** 50-200KB per image
- **Total Pack Size:** 1-5MB recommended
- **Loading Time:** <2 seconds for full pack
- **Cache Efficiency:** 90%+ hit rate after first load

## Quick Reference

### Adding a New Pack (Checklist)

- [ ] Prepare 6-12 high-quality images (400x400px)
- [ ] Upload images to reliable CDN
- [ ] Generate unique pack ID
- [ ] Add pack object to `packs` array
- [ ] Update `totalPacks` count
- [ ] Update `lastUpdated` timestamp
- [ ] Update category `packCount` if needed
- [ ] Validate JSON syntax
- [ ] Test in development
- [ ] Commit changes with descriptive message

### Image URL Template

```
https://images.unsplash.com/photo-[ID]?w=400&h=400&fit=crop&q=80
```

### Pack ID Naming Convention

```
[category]_[theme]_[variant]
Examples:
- animals_farm_domestic
- nature_mountains_alpine
- vintage_cars_classic
- food_desserts_homemade
```

### Difficulty Guidelines

| Difficulty | Grid Size | Image Count | Target Audience |
|------------|-----------|-------------|-----------------|
| Easy       | 3x4       | 6-8         | Beginners       |
| Medium     | 4x4       | 8-12        | Regular players |
| Hard       | 5x5       | 12-20       | Experienced     |
| Brainy     | 6x6       | 20-36       | Experts         |

### JSON Validation Command

```bash
# Validate JSON syntax
cat assets/data/packs_index.json | python -m json.tool > /dev/null && echo "Valid JSON" || echo "Invalid JSON"
```

---

For technical support or questions about pack management, refer to the main README.md or contact the development team.
