# Guide to Update `packs_index.json`

## Overview

The `packs_index.json` file contains metadata about the available memory packs in the Golden Moments application. This file manages categories, featured packs, and individual pack configurations. Updating this file ensures that new packs are added, existing packs are modified, or outdated packs are removed.

## File Structure

The `packs_index.json` file follows this structure:

```json
{
  "version": "1.0.0",
  "lastUpdated": "2025-07-10T14:30:00Z",
  "totalPacks": 8,
  "categories": [...],
  "featuredPacks": [...],
  "packs": [...]
}
```

### Root Level Properties

- **version**: Current version of the pack index
- **lastUpdated**: ISO timestamp of last update
- **totalPacks**: Total number of available packs
- **categories**: Array of pack categories with metadata
- **featuredPacks**: Array of pack IDs that should be featured
- **packs**: Array of individual pack objects

### Category Structure

```json
{
  "id": "category_id",
  "name": "Category Name",
  "description": "Category description",
  "iconUrl": "https://example.com/icon.jpg",
  "packCount": 2
}
```

### Pack Structure

Each pack in the `packs` array follows this detailed structure:

```json
{
  "id": "unique_pack_id",
  "title": "Pack Title",
  "description": "Pack description",
  "theme": "Pack Theme",
  "category": "category_id",
  "difficulty": "easy|medium|hard|brainy",
  "isPremium": false,
  "isFeatured": true,
  "imageCount": 6,
  "estimatedSize": "2.1 MB",
  "version": "1.0.0",
  "createdAt": "2025-01-01T00:00:00Z",
  "updatedAt": "2025-01-01T00:00:00Z",
  "tags": ["tag1", "tag2", "tag3"],
  "thumbnailUrl": "https://example.com/thumbnail.jpg",
  "previewImages": ["url1", "url2", "url3"],
  "images": [
    {
      "id": "image_id",
      "url": "https://example.com/image.jpg",
      "caption": "Image Caption"
    }
  ]
}
```

## Steps to Update

### 1. **Add a New Category**

To add a new category:

1. Add the category object to the `categories` array
2. Update the category's `packCount` as you add packs
3. Ensure the category `id` is unique

Example:

```json
{
  "id": "sports",
  "name": "Sports",
  "description": "Athletic activities and sports moments",
  "iconUrl": "https://images.unsplash.com/photo-sports-icon?w=100&h=100&fit=crop",
  "packCount": 0
}
```

### 2. **Add a New Pack**

To add a new pack:

1. Create a new pack object with all required fields
2. Ensure the `id` is unique across all packs
3. Add the pack to the `packs` array
4. Update `totalPacks` count
5. Update the corresponding category's `packCount`
6. Add to `featuredPacks` array if it should be featured
7. Update `lastUpdated` timestamp

Example:

```json
{
  "id": "sports_soccer",
  "title": "Soccer Moments",
  "description": "Exciting soccer matches and memorable goals",
  "theme": "Soccer",
  "category": "sports",
  "difficulty": "medium",
  "isPremium": false,
  "isFeatured": true,
  "imageCount": 8,
  "estimatedSize": "2.5 MB",
  "version": "1.0.0",
  "createdAt": "2025-07-31T00:00:00Z",
  "updatedAt": "2025-07-31T00:00:00Z",
  "tags": ["soccer", "football", "sports", "medium"],
  "thumbnailUrl": "https://images.unsplash.com/photo-soccer-thumb?w=300&h=200&fit=crop",
  "previewImages": [
    "https://images.unsplash.com/photo-soccer1?w=150&h=150&fit=crop",
    "https://images.unsplash.com/photo-soccer2?w=150&h=150&fit=crop",
    "https://images.unsplash.com/photo-soccer3?w=150&h=150&fit=crop"
  ],
  "images": [
    {
      "id": "soccer_goal_1",
      "url": "https://images.unsplash.com/photo-soccer-goal?w=400&h=400&fit=crop",
      "caption": "Amazing Goal"
    }
  ]
}
```

### 3. **Update an Existing Pack**

To update an existing pack:

1. Locate the pack by its `id` in the `packs` array
2. Modify the fields that need updating
3. Update the `updatedAt` timestamp
4. Update `version` if significant changes are made
5. Update `lastUpdated` timestamp at root level

Example - Updating difficulty and adding images:

Before:

```json
{
  "id": "animals_farm",
  "difficulty": "medium",
  "imageCount": 8,
  "version": "1.0.0"
}
```

After:

```json
{
  "id": "animals_farm",
  "difficulty": "easy",
  "imageCount": 10,
  "version": "1.1.0",
  "updatedAt": "2025-07-31T12:00:00Z"
}
```

### 4. **Remove a Pack**

To remove a pack:

1. Locate the pack by its `id` in the `packs` array
2. Remove the pack object from the array
3. Update `totalPacks` count (decrease by 1)
4. Update the corresponding category's `packCount` (decrease by 1)
5. Remove from `featuredPacks` array if it was featured
6. Update `lastUpdated` timestamp

### 5. **Update Featured Packs**

To modify which packs are featured:

1. Update the `featuredPacks` array with pack IDs
2. Ensure corresponding packs have `isFeatured: true`
3. Update `lastUpdated` timestamp

Example:

```json
"featuredPacks": ["animals_farm", "nature_mountains", "vintage_cars", "new_featured_pack"]
```

### 6. **Manage Pack Categories**

When adding/removing packs, always update category counts:

1. Find the category in the `categories` array
2. Update the `packCount` field
3. If removing the last pack from a category, consider removing the category

Example:

```json
{
  "id": "animals",
  "name": "Animals",
  "packCount": 3
}
```

### 7. **Field Specifications**

#### Required Fields for Packs:

- `id`: Unique identifier (string)
- `title`: Display name (string)
- `description`: Pack description (string)
- `theme`: Pack theme (string)
- `category`: Must match a category ID (string)
- `difficulty`: "easy", "medium", "hard", or "brainy" (string)
- `isPremium`: Boolean indicating premium status
- `isFeatured`: Boolean indicating featured status
- `imageCount`: Number of images in pack (integer)
- `estimatedSize`: Size with units (string, e.g., "2.1 MB")
- `version`: Semantic version (string)
- `createdAt`: ISO timestamp (string)
- `updatedAt`: ISO timestamp (string)
- `tags`: Array of strings for search/filtering
- `thumbnailUrl`: Main pack image URL (string)
- `previewImages`: Array of 3 preview image URLs
- `images`: Array of image objects with `id`, `url`, and `caption`

#### Difficulty Levels:

- **easy**: Minimum 6 images, simple matching (3x4 grid)
- **medium**: Minimum 8 images, moderate challenge (4x4 grid)
- **hard**: Minimum 10 images, challenging matching (4x4 grid with more pairs)
- **brainy**: Minimum 16 images, very challenging (5x5 grid)

#### Image URL Format:

Use Unsplash URLs with consistent sizing:

- Thumbnails: `?w=300&h=200&fit=crop`
- Previews: `?w=150&h=150&fit=crop`
- Game images: `?w=400&h=400&fit=crop`
- Category icons: `?w=100&h=100&fit=crop`

### 8. **Validate the JSON**

After making changes:

1. Use a JSON validator to ensure the file is correctly formatted
2. Check for trailing commas or missing brackets
3. Verify all required fields are present
4. Ensure all category references exist
5. Validate that `totalPacks` matches actual pack count
6. Verify `packCount` in categories matches actual packs per category

### 9. **Testing Checklist**

After updating the file:

1. ✅ JSON syntax is valid
2. ✅ All pack IDs are unique
3. ✅ All category IDs referenced by packs exist
4. ✅ `totalPacks` count is accurate
5. ✅ Category `packCount` values are accurate
6. ✅ Featured packs exist and have `isFeatured: true`
7. ✅ All image URLs are accessible
8. ✅ Timestamp format is ISO 8601
9. ✅ Version numbers follow semantic versioning
10. ✅ Packs meet minimum image requirements for their difficulty level
11. ✅ Run the application to verify packs display correctly

### 10. **Common Mistakes to Avoid**

- ❌ Forgetting to update `totalPacks` when adding/removing packs
- ❌ Not updating category `packCount` when modifying packs
- ❌ Using non-unique pack IDs
- ❌ Referencing non-existent category IDs
- ❌ Inconsistent image URL sizing parameters
- ❌ Missing required fields in pack objects
- ❌ Forgetting to update `lastUpdated` timestamp
- ❌ Invalid JSON syntax (trailing commas, missing quotes)
- ❌ Incorrect difficulty level values
- ❌ Mismatched `imageCount` with actual images array length
- ❌ Not meeting minimum image requirements (easy: 6+, medium: 8+, hard: 10+, brainy: 16+)

### 11. **Best Practices**

- 📝 Always backup the file before making changes
- 🏷️ Use descriptive and consistent naming for pack IDs
- 📅 Update timestamps when making any changes
- 🖼️ Test all image URLs before committing
- 📊 Keep category pack counts accurate
- 🔍 Use meaningful tags for better searchability
- 📱 Ensure thumbnail and preview images are optimized
- 🎯 Balance difficulty levels across categories
- 📝 Write clear, engaging descriptions
- 🌟 Be selective with featured packs to maintain quality
