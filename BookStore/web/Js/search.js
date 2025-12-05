/**
 * ============================================
 * E-BOOKS ADVANCED SEARCH SYSTEM
 * Desktop & Mobile AJAX Search
 * Version: 2.1 (Fixed for MVC Entity)
 * ============================================
 */

'use strict';

// ==================== CONFIGURATION ====================
const SEARCH_CONFIG = {
    debounceDelay: 300,
    minSearchLength: 1,
    maxResults: 10,
    servletUrl: 'SearchServlet'
};

// ==================== STATE MANAGEMENT ====================
const searchState = {
    desktop: { timeout: null, input: null, results: null },
    mobile: { timeout: null, input: null, results: null },
    currentRequest: null
};

// ==================== INITIALIZATION ====================
document.addEventListener('DOMContentLoaded', function() {
    initializeSearch();
});

function initializeSearch() {
    searchState.desktop.input = document.getElementById('searchInput');
    searchState.desktop.results = document.getElementById('searchResults');
    searchState.mobile.input = document.getElementById('searchInputMobile');
    
    // Setup Mobile Results Container
    if (searchState.mobile.input) {
        let container = document.getElementById('searchResultsMobile');
        if (!container) {
            container = document.createElement('div');
            container.id = 'searchResultsMobile';
            container.className = 'search-results mobile-search-results';
            searchState.mobile.input.parentElement.appendChild(container);
        }
        searchState.mobile.results = container;
    }
    
    // Setup Listeners
    if (searchState.desktop.input) setupSearchBox('desktop');
    if (searchState.mobile.input) setupSearchBox('mobile');
    
    setupClickOutsideHandler();
}

function setupSearchBox(type) {
    const state = searchState[type];
    
    state.input.addEventListener('input', (e) => handleSearchInput(e.target.value.trim(), type));
    
    state.input.addEventListener('focus', (e) => {
        if (e.target.value.trim().length >= SEARCH_CONFIG.minSearchLength) {
            performSearch(e.target.value.trim(), type);
        }
    });

    state.input.addEventListener('keydown', (e) => {
        if (e.key === 'Enter') {
            e.preventDefault();
            if (state.input.value.trim()) redirectToSearchPage(state.input.value.trim());
        }
    });
}

function handleSearchInput(query, type) {
    const state = searchState[type];
    clearTimeout(state.timeout);
    
    if (query.length < SEARCH_CONFIG.minSearchLength) {
        hideResults(type);
        return;
    }
    
    showLoadingState(type);
    
    state.timeout = setTimeout(() => {
        performSearch(query, type);
    }, SEARCH_CONFIG.debounceDelay);
}

// ==================== AJAX SEARCH ====================
async function performSearch(query, type) {
    try {
        if (searchState.currentRequest) searchState.currentRequest.abort();
        
        const controller = new AbortController();
        searchState.currentRequest = controller;
        
        const response = await fetch(
            `${SEARCH_CONFIG.servletUrl}?query=${encodeURIComponent(query)}`,
            { signal: controller.signal }
        );
        
        const books = await response.json();
        displayResults(books, type);
        
    } catch (error) {
        if (error.name !== 'AbortError') {
            console.error('Search error:', error);
            showErrorState(type);
        }
    }
}

// ==================== DISPLAY RESULTS ====================
function displayResults(books, type) {
    const state = searchState[type];
    if (!state.results) return;
    
    if (!books || books.length === 0) {
        showNoResults(type);
        return;
    }
    
    // Tạo HTML từ mảng sách
    const html = books.map(book => createBookHTML(book)).join('');
    state.results.innerHTML = html;
    state.results.classList.add('active');
}

function createBookHTML(book) {
    // Logic giá tiền: Nhân 300 theo quy ước dự án
    const priceVND = parseFloat(book.price) * 300;
    const formattedPrice = priceVND.toLocaleString('vi-VN') + '₫';
    
    // LƯU Ý QUAN TRỌNG: Sử dụng book.name thay vì book.title để khớp với Entity Book
    const safeName = escapeHTML(book.name);
    const imageUrl = book.image && book.image.trim() !== '' ? book.image : 'images/default-book.jpg';
    
    return `
        <div class="search-result-item" onclick="selectBook('${safeName.replace(/'/g, "\\'")}', ${book.id})">
            <img src="${imageUrl}" 
                 alt="${safeName}" 
                 onerror="this.src='images/default-book.jpg'">
            <div class="book-details">
                <div class="book-title">${book.name}</div>
                <div class="book-author">
                    <i class="fas fa-user-edit"></i> ${book.author}
                </div>
                <div class="book-price">
                    ${formattedPrice}
                </div>
            </div>
        </div>
    `;
}

// ==================== UI HELPERS ====================
function showLoadingState(type) {
    const state = searchState[type];
    if (state.results) {
        state.results.innerHTML = '<div class="search-message"><i class="fas fa-spinner fa-spin"></i> Đang tìm kiếm...</div>';
        state.results.classList.add('active');
    }
}

function showNoResults(type) {
    const state = searchState[type];
    if (state.results) {
        state.results.innerHTML = '<div class="search-message"><i class="far fa-sad-tear"></i> Không tìm thấy sách nào.</div>';
        state.results.classList.add('active');
    }
}

function showErrorState(type) {
    const state = searchState[type];
    if (state.results) {
        state.results.innerHTML = '<div class="search-message text-danger"><i class="fas fa-exclamation-triangle"></i> Lỗi kết nối.</div>';
        state.results.classList.add('active');
    }
}

function hideResults(type) {
    const state = searchState[type];
    if (state.results) state.results.classList.remove('active');
}

function escapeHTML(text) {
    if (!text) return "";
    return text.replace(/[&<>"']/g, function(m) {
        return { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#039;' }[m];
    });
}

// ==================== GLOBAL ACTIONS ====================
window.selectBook = function(name, bookId) {
    if (searchState.desktop.input) searchState.desktop.input.value = name;
    if (searchState.mobile.input) searchState.mobile.input.value = name;
    
    hideResults('desktop');
    hideResults('mobile');
    
    window.location.href = `book-detail.jsp?id=${bookId}`;
};

function redirectToSearchPage(query) {
    window.location.href = `index.jsp?search=${encodeURIComponent(query)}#Featuredbooks`;
}

function setupClickOutsideHandler() {
    document.addEventListener('click', (e) => {
        if (!e.target.closest('.search-container')) hideResults('desktop');
        if (!e.target.closest('.mobile-search')) hideResults('mobile');
    });
}