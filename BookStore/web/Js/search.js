/**
 * ============================================
 * E-BOOKS ADVANCED SEARCH SYSTEM
 * Desktop & Mobile AJAX Search
 * Version: 2.0
 * ============================================
 */

'use strict';

// ==================== CONFIGURATION ====================
const SEARCH_CONFIG = {
    debounceDelay: 300,
    minSearchLength: 1,
    maxResults: 12,
    servletUrl: 'SearchServlet'
};

// ==================== STATE MANAGEMENT ====================
const searchState = {
    desktop: {
        timeout: null,
        input: null,
        results: null
    },
    mobile: {
        timeout: null,
        input: null,
        results: null
    },
    currentRequest: null
};

// ==================== INITIALIZATION ====================
document.addEventListener('DOMContentLoaded', function() {
    console.log('🚀 Initializing E-Books Search System...');
    
    initializeSearch();
    initializeCategoryFilter();
    initializeSlideshow();
    
    console.log('✅ Search System Ready');
});

/**
 * Initialize search functionality
 */
function initializeSearch() {
    // Get elements
    searchState.desktop.input = document.getElementById('searchInput');
    searchState.desktop.results = document.getElementById('searchResults');
    searchState.mobile.input = document.getElementById('searchInputMobile');
    
    // Validate
    if (!searchState.desktop.input && !searchState.mobile.input) {
        console.warn('⚠️ Search inputs not found');
        return;
    }
    
    // Setup mobile results container
    if (searchState.mobile.input) {
        searchState.mobile.results = createMobileResultsContainer();
    }
    
    // Setup desktop search
    if (searchState.desktop.input && searchState.desktop.results) {
        setupSearchBox('desktop');
    }
    
    // Setup mobile search
    if (searchState.mobile.input && searchState.mobile.results) {
        setupSearchBox('mobile');
        setupMobileSubmitButton();
    }
    
    // Setup click outside handler
    setupClickOutsideHandler();
    
    console.log('✅ Search initialized');
}

/**
 * Create mobile search results container
 */
function createMobileResultsContainer() {
    let container = document.getElementById('searchResultsMobile');
    
    if (!container) {
        container = document.createElement('div');
        container.id = 'searchResultsMobile';
        container.className = 'search-results mobile-search-results';
        searchState.mobile.input.parentElement.appendChild(container);
    }
    
    return container;
}

// ==================== SEARCH BOX SETUP ====================

/**
 * Setup search box (desktop or mobile)
 */
function setupSearchBox(type) {
    const state = searchState[type];
    
    // Input event - debounced search
    state.input.addEventListener('input', function(e) {
        handleSearchInput(e.target.value.trim(), type);
    });
    
    // Focus event - show previous results
    state.input.addEventListener('focus', function(e) {
        const value = e.target.value.trim();
        if (value.length >= SEARCH_CONFIG.minSearchLength) {
            performSearch(value, type);
        }
    });
    
    // Keydown event - shortcuts
    state.input.addEventListener('keydown', function(e) {
        if (e.key === 'Escape') {
            clearSearchBox(type);
        } else if (e.key === 'Enter') {
            e.preventDefault();
            const value = state.input.value.trim();
            if (value) {
                redirectToSearchPage(value);
            }
        }
    });
    
    // Keyup event - clear results when empty
    state.input.addEventListener('keyup', function(e) {
        if (e.target.value === '') {
            hideResults(type);
        }
    });
}

/**
 * Setup mobile submit button
 */
function setupMobileSubmitButton() {
    const submitBtn = document.querySelector('.mobile-search .search-submit');
    
    if (submitBtn) {
        submitBtn.addEventListener('click', function() {
            const value = searchState.mobile.input.value.trim();
            if (value) {
                hideResults('mobile');
                redirectToSearchPage(value);
            }
        });
    }
}

// ==================== SEARCH INPUT HANDLING ====================

/**
 * Handle search input with debouncing
 */
function handleSearchInput(query, type) {
    const state = searchState[type];
    
    // Clear previous timeout
    clearTimeout(state.timeout);
    
    // Hide if query too short
    if (query.length < SEARCH_CONFIG.minSearchLength) {
        hideResults(type);
        return;
    }
    
    // Show loading immediately
    showLoadingState(type);
    
    // Debounce search
    state.timeout = setTimeout(() => {
        performSearch(query, type);
    }, SEARCH_CONFIG.debounceDelay);
}

// ==================== AJAX SEARCH ====================

/**
 * Perform AJAX search
 */
async function performSearch(query, type) {
    const state = searchState[type];
    
    try {
        // Cancel previous request
        if (searchState.currentRequest) {
            searchState.currentRequest.abort();
        }
        
        // Create new request with abort controller
        const controller = new AbortController();
        searchState.currentRequest = controller;
        
        // Fetch from servlet
        const response = await fetch(
            `${SEARCH_CONFIG.servletUrl}?query=${encodeURIComponent(query)}`,
            { signal: controller.signal }
        );
        
        // Check response
        if (!response.ok) {
            throw new Error(`HTTP ${response.status}`);
        }
        
        // Parse JSON
        const books = await response.json();
        
        // Display results
        displayResults(books, type);
        
    } catch (error) {
        // Handle abort (user typed new query)
        if (error.name === 'AbortError') {
            console.log('🔄 Search cancelled');
            return;
        }
        
        // Handle other errors
        console.error('❌ Search error:', error);
        showErrorState(type);
        
    } finally {
        searchState.currentRequest = null;
    }
}

// ==================== DISPLAY RESULTS ====================

/**
 * Display search results
 */
function displayResults(books, type) {
    const state = searchState[type];
    
    if (!state.results) return;
    
    if (!books || books.length === 0) {
        showNoResults(type);
        return;
    }
    
    // Build HTML
    const html = books.map(book => createBookHTML(book)).join('');
    
    // Display
    state.results.innerHTML = html;
    state.results.classList.add('active');
}

/**
 * Create HTML for single book
 */
function createBookHTML(book) {
    const priceVND = parseFloat(book.price) * 300;
    const formattedPrice = priceVND.toLocaleString('vi-VN') + '₫';
    const safeTitle = escapeHTML(book.title);
    
    return `
        <div class="search-result-item" onclick="selectBook('${safeTitle}', ${book.id})">
            <img src="${book.image}" 
                 alt="${safeTitle}" 
                 onerror="this.src='images/default-book.jpg'"
                 loading="lazy">
            <div class="book-details">
                <div class="book-title">${book.title}</div>
                <div class="book-author">
                    <i class="fas fa-user"></i> ${book.author}
                </div>
                <div class="book-price">
                    <i class="fas fa-tag"></i> ${formattedPrice}
                </div>
                <div class="book-category">
                    <i class="fas fa-bookmark"></i> ${book.category}
                </div>
            </div>
        </div>
    `;
}

// ==================== UI STATES ====================

/**
 * Show loading state
 */
function showLoadingState(type) {
    const state = searchState[type];
    
    if (state.results) {
        state.results.innerHTML = `
            <div class="search-loading">
                <i class="fas fa-spinner fa-spin"></i>
                <span>Đang tìm kiếm...</span>
            </div>
        `;
        state.results.classList.add('active');
    }
}

/**
 * Show no results state
 */
function showNoResults(type) {
    const state = searchState[type];
    
    if (state.results) {
        state.results.innerHTML = `
            <div class="no-results">
                <i class="fas fa-search"></i>
                <p>Không tìm thấy sách nào</p>
            </div>
        `;
        state.results.classList.add('active');
    }
}

/**
 * Show error state
 */
function showErrorState(type) {
    const state = searchState[type];
    
    if (state.results) {
        state.results.innerHTML = `
            <div class="no-results">
                <i class="fas fa-exclamation-triangle"></i>
                <p>Đã xảy ra lỗi. Vui lòng thử lại.</p>
            </div>
        `;
        state.results.classList.add('active');
    }
}

/**
 * Hide results
 */
function hideResults(type) {
    const state = searchState[type];
    
    if (state.results) {
        state.results.classList.remove('active');
    }
}

/**
 * Clear search box
 */
function clearSearchBox(type) {
    const state = searchState[type];
    
    if (state.input) {
        state.input.value = '';
    }
    
    hideResults(type);
}

// ==================== BOOK SELECTION ====================

/**
 * Handle book selection (global function)
 */
window.selectBook = function(title, bookId) {
    // Update both inputs
    if (searchState.desktop.input) {
        searchState.desktop.input.value = title;
    }
    if (searchState.mobile.input) {
        searchState.mobile.input.value = title;
    }
    
    // Hide all results
    hideResults('desktop');
    hideResults('mobile');
    
    // Redirect
    if (bookId) {
        window.location.href = `book-detail.jsp?id=${bookId}`;
    } else {
        redirectToSearchPage(title);
    }
};

/**
 * Redirect to search results page
 */
function redirectToSearchPage(query) {
    window.location.href = `index.jsp?search=${encodeURIComponent(query)}#Featuredbooks`;
}

// ==================== CLICK OUTSIDE HANDLER ====================

/**
 * Setup click outside to close results
 */
function setupClickOutsideHandler() {
    document.addEventListener('click', function(e) {
        // Desktop
        if (searchState.desktop.input && searchState.desktop.results) {
            const container = searchState.desktop.input.closest('.search-container');
            if (container && 
                !container.contains(e.target) && 
                !searchState.desktop.results.contains(e.target)) {
                hideResults('desktop');
            }
        }
        
        // Mobile
        if (searchState.mobile.input && searchState.mobile.results) {
            const container = searchState.mobile.input.closest('.mobile-search');
            if (container && 
                !container.contains(e.target) && 
                !searchState.mobile.results.contains(e.target)) {
                hideResults('mobile');
            }
        }
    });
}

// ==================== UTILITY FUNCTIONS ====================

/**
 * Escape HTML to prevent XSS
 */
function escapeHTML(text) {
    const map = {
        '&': '&amp;',
        '<': '&lt;',
        '>': '&gt;',
        '"': '&quot;',
        "'": '&#039;'
    };
    return text.replace(/[&<>"']/g, m => map[m]);
}

// ==================== CATEGORY FILTER ====================

/**
 * Initialize category filter
 */
function initializeCategoryFilter() {
    const filterButtons = document.querySelectorAll('.filter-btn');
    const bookCards = document.querySelectorAll('.book-card');

    if (!filterButtons.length) return;

    filterButtons.forEach(button => {
        button.addEventListener('click', function() {
            // Update active state
            filterButtons.forEach(btn => btn.classList.remove('active'));
            this.classList.add('active');

            const category = this.getAttribute('data-category').toLowerCase();

            // Filter books
            bookCards.forEach(card => {
                const cardCategory = card.getAttribute('data-category').toLowerCase();
                
                card.style.display = (category === 'all' || cardCategory === category) 
                    ? 'block' 
                    : 'none';
            });
        });
    });
}

// ==================== SLIDESHOW ====================

/**
 * Initialize slideshow
 */
function initializeSlideshow() {
    const slides = document.getElementsByClassName("slides");
    if (slides.length === 0) return;
    
    let slideIndex = 1;
    let slideInterval;
    
    function showSlides(n) {
        const dots = document.getElementsByClassName("dot");
        
        if (n > slides.length) slideIndex = 1;
        if (n < 1) slideIndex = slides.length;
        
        // Hide all
        for (let i = 0; i < slides.length; i++) {
            slides[i].classList.remove("active");
            if (dots[i]) dots[i].classList.remove("active");
        }
        
        // Show current
        slides[slideIndex - 1].classList.add("active");
        if (dots[slideIndex - 1]) {
            dots[slideIndex - 1].classList.add("active");
        }
    }
    
    function startSlideshow() {
        slideInterval = setInterval(() => {
            slideIndex++;
            showSlides(slideIndex);
        }, 5000);
    }
    
    // Global controls
    window.changeSlide = function(n) {
        clearInterval(slideInterval);
        slideIndex += n;
        showSlides(slideIndex);
        startSlideshow();
    };
    
    window.currentSlide = function(n) {
        clearInterval(slideInterval);
        slideIndex = n;
        showSlides(slideIndex);
        startSlideshow();
    };
    
    // Start
    showSlides(slideIndex);
    startSlideshow();
}

// ==================== END ====================
console.log('📚 E-Books Search Module Loaded');