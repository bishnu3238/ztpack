const express = require('express');
const bodyParser = require('body-parser');
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const { v4: uuidv4 } = require('uuid');

const app = express();
const port = process.env.PORT || 3000;

// Middleware
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

// Configure multer for file uploads
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    const uploadDir = path.join(__dirname, 'uploads', req.params.itemId || 'temp');
    
    // Create directory if it doesn't exist
    if (!fs.existsSync(uploadDir)) {
      fs.mkdirSync(uploadDir, { recursive: true });
    }
    
    cb(null, uploadDir);
  },
  filename: (req, file, cb) => {
    const uniqueName = `${uuidv4()}${path.extname(file.originalname)}`;
    cb(null, uniqueName);
  }
});

const upload = multer({
  storage,
  limits: { fileSize: 5 * 1024 * 1024 }, // 5MB limit
  fileFilter: (req, file, cb) => {
    // Accept only images
    if (file.mimetype.startsWith('image/')) {
      cb(null, true);
    } else {
      cb(new Error('Only image files are allowed'));
    }
  }
});

// Serve static files from uploads directory
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// In-memory database (replace with a real database in production)
let reviews = [];
let ratingSummaries = {};

// Helper function to calculate rating summary
function calculateRatingSummary(itemId) {
  const itemReviews = reviews.filter(review => review.itemId === itemId);
  
  if (itemReviews.length === 0) {
    return {
      itemId,
      averageRating: 0,
      totalReviews: 0,
      ratingCounts: { '1': 0, '2': 0, '3': 0, '4': 0, '5': 0 }
    };
  }
  
  let sum = 0;
  const ratingCounts = { '1': 0, '2': 0, '3': 0, '4': 0, '5': 0 };
  
  itemReviews.forEach(review => {
    sum += review.rating;
    const ratingKey = Math.round(review.rating).toString();
    ratingCounts[ratingKey] = (ratingCounts[ratingKey] || 0) + 1;
  });
  
  const averageRating = sum / itemReviews.length;
  
  return {
    itemId,
    averageRating,
    totalReviews: itemReviews.length,
    ratingCounts
  };
}

// API Routes

// Get reviews for an item
app.get('/api/reviews', (req, res) => {
  const { 
    itemId, 
    page = 1, 
    limit = 10, 
    sortBy = 'createdAt', 
    sortOrder = 'desc',
    minRating,
    maxRating
  } = req.query;
  
  if (!itemId) {
    return res.status(400).json({ error: 'itemId is required' });
  }
  
  // Filter reviews
  let filteredReviews = reviews.filter(review => review.itemId === itemId);
  
  if (minRating) {
    filteredReviews = filteredReviews.filter(review => review.rating >= Number(minRating));
  }
  
  if (maxRating) {
    filteredReviews = filteredReviews.filter(review => review.rating <= Number(maxRating));
  }
  
  // Sort reviews
  filteredReviews.sort((a, b) => {
    const aValue = a[sortBy];
    const bValue = b[sortBy];
    
    if (typeof aValue === 'string') {
      return sortOrder === 'desc' 
        ? bValue.localeCompare(aValue) 
        : aValue.localeCompare(bValue);
    }
    
    return sortOrder === 'desc' ? bValue - aValue : aValue - bValue;
  });
  
  // Paginate
  const startIndex = (Number(page) - 1) * Number(limit);
  const endIndex = startIndex + Number(limit);
  const paginatedReviews = filteredReviews.slice(startIndex, endIndex);
  
  res.json({
    reviews: paginatedReviews,
    totalCount: filteredReviews.length,
    page: Number(page),
    limit: Number(limit),
    totalPages: Math.ceil(filteredReviews.length / Number(limit))
  });
});

// Get a specific review
app.get('/api/reviews/:reviewId', (req, res) => {
  const { reviewId } = req.params;
  const review = reviews.find(r => r.id === reviewId);
  
  if (!review) {
    return res.status(404).json({ error: 'Review not found' });
  }
  
  res.json(review);
});

// Submit a new review
app.post('/api/reviews', upload.array('images', 5), (req, res) => {
  try {
    let reviewData;
    
    // Parse review data
    if (req.body.review) {
      reviewData = JSON.parse(req.body.review);
    } else {
      reviewData = req.body;
    }
    
    const { userId, userName, itemId, rating } = reviewData;
    
    // Validate required fields
    if (!userId || !userName || !itemId || !rating) {
      return res.status(400).json({ error: 'Missing required fields' });
    }
    
    // Check if user has already reviewed this item
    const existingReview = reviews.find(r => r.itemId === itemId && r.userId === userId);
    if (existingReview) {
      return res.status(400).json({ error: 'User has already reviewed this item' });
    }
    
    // Process uploaded images
    const imageUrls = [];
    if (req.files && req.files.length > 0) {
      req.files.forEach(file => {
        const imageUrl = `/uploads/${itemId}/${file.filename}`;
        imageUrls.push(imageUrl);
      });
    }
    
    // Create review
    const now = new Date().toISOString();
    const review = {
      id: reviewData.id || uuidv4(),
      userId,
      userName,
      userImageUrl: reviewData.userImageUrl,
      itemId,
      rating: Number(rating),
      title: reviewData.title,
      content: reviewData.content,
      imageUrls,
      createdAt: now,
      updatedAt: now,
      isVerified: false,
      responses: [],
      helpfulCount: 0,
      metadata: reviewData.metadata
    };
    
    // Save review
    reviews.push(review);
    
    // Update rating summary
    ratingSummaries[itemId] = calculateRatingSummary(itemId);
    
    res.status(201).json(review);
  } catch (error) {
    console.error('Error submitting review:', error);
    res.status(500).json({ error: 'Failed to submit review' });
  }
});

// Update a review
app.put('/api/reviews/:reviewId', upload.array('images', 5), (req, res) => {
  try {
    const { reviewId } = req.params;
    let reviewData;
    
    // Parse review data
    if (req.body.review) {
      reviewData = JSON.parse(req.body.review);
    } else {
      reviewData = req.body;
    }
    
    // Find existing review
    const reviewIndex = reviews.findIndex(r => r.id === reviewId);
    if (reviewIndex === -1) {
      return res.status(404).json({ error: 'Review not found' });
    }
    
    const existingReview = reviews[reviewIndex];
    
    // Verify ownership
    if (existingReview.userId !== reviewData.userId) {
      return res.status(403).json({ error: 'User does not own this review' });
    }
    
    // Process uploaded images
    const imageUrls = [];
    if (req.files && req.files.length > 0) {
      // Delete existing images (in a real app, you'd delete the files)
      
      // Add new images
      req.files.forEach(file => {
        const imageUrl = `/uploads/${existingReview.itemId}/${file.filename}`;
        imageUrls.push(imageUrl);
      });
    } else {
      // Keep existing images
      imageUrls.push(...existingReview.imageUrls);
    }
    
    // Update review
    const now = new Date().toISOString();
    const updatedReview = {
      ...existingReview,
      userName: reviewData.userName || existingReview.userName,
      userImageUrl: reviewData.userImageUrl || existingReview.userImageUrl,
      rating: Number(reviewData.rating) || existingReview.rating,
      title: reviewData.title !== undefined ? reviewData.title : existingReview.title,
      content: reviewData.content || existingReview.content,
      imageUrls,
      updatedAt: now,
      metadata: reviewData.metadata || existingReview.metadata
    };
    
    // Save updated review
    reviews[reviewIndex] = updatedReview;
    
    // Update rating summary
    ratingSummaries[existingReview.itemId] = calculateRatingSummary(existingReview.itemId);
    
    res.json(updatedReview);
  } catch (error) {
    console.error('Error updating review:', error);
    res.status(500).json({ error: 'Failed to update review' });
  }
});

// Delete a review
app.delete('/api/reviews/:reviewId', (req, res) => {
  const { reviewId } = req.params;
  
  // Find review
  const reviewIndex = reviews.findIndex(r => r.id === reviewId);
  if (reviewIndex === -1) {
    return res.status(404).json({ error: 'Review not found' });
  }
  
  const review = reviews[reviewIndex];
  
  // Delete review
  reviews.splice(reviewIndex, 1);
  
  // Update rating summary
  ratingSummaries[review.itemId] = calculateRatingSummary(review.itemId);
  
  res.status(200).json({ success: true });
});

// Add a response to a review
app.post('/api/reviews/:reviewId/responses', (req, res) => {
  const { reviewId } = req.params;
  const responseData = req.body;
  
  // Validate required fields
  if (!responseData.userId || !responseData.userName || !responseData.content) {
    return res.status(400).json({ error: 'Missing required fields' });
  }
  
  // Find review
  const reviewIndex = reviews.findIndex(r => r.id === reviewId);
  if (reviewIndex === -1) {
    return res.status(404).json({ error: 'Review not found' });
  }
  
  // Create response
  const now = new Date().toISOString();
  const response = {
    id: responseData.id || uuidv4(),
    userId: responseData.userId,
    userName: responseData.userName,
    userImageUrl: responseData.userImageUrl,
    content: responseData.content,
    createdAt: now,
    isOfficial: responseData.isOfficial || false
  };
  
  // Add response to review
  reviews[reviewIndex].responses.push(response);
  reviews[reviewIndex].updatedAt = now;
  
  res.status(201).json(reviews[reviewIndex]);
});

// Mark a review as helpful
app.post('/api/reviews/:reviewId/helpful', (req, res) => {
  const { reviewId } = req.params;
  const { isHelpful } = req.body;
  
  // Find review
  const reviewIndex = reviews.findIndex(r => r.id === reviewId);
  if (reviewIndex === -1) {
    return res.status(404).json({ error: 'Review not found' });
  }
  
  // Update helpful count
  if (isHelpful) {
    reviews[reviewIndex].helpfulCount += 1;
  } else {
    reviews[reviewIndex].helpfulCount = Math.max(0, reviews[reviewIndex].helpfulCount - 1);
  }
  
  res.json({ success: true, helpfulCount: reviews[reviewIndex].helpfulCount });
});

// Get rating summary for an item
app.get('/api/items/:itemId/rating-summary', (req, res) => {
  const { itemId } = req.params;
  
  // Calculate or retrieve rating summary
  const summary = ratingSummaries[itemId] || calculateRatingSummary(itemId);
  
  // Cache the summary
  ratingSummaries[itemId] = summary;
  
  res.json(summary);
});

// Check if a user has reviewed an item
app.get('/api/reviews/check', (req, res) => {
  const { itemId, userId } = req.query;
  
  if (!itemId || !userId) {
    return res.status(400).json({ error: 'itemId and userId are required' });
  }
  
  const existingReview = reviews.find(r => r.itemId === itemId && r.userId === userId);
  
  res.json({ hasReviewed: !!existingReview });
});

// Start server
app.listen(port, () => {
  console.log(`Review API server running on port ${port}`);
});

module.exports = app; // For testing