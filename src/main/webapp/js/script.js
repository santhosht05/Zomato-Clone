/**
 * SwadhaFood – Core Client-side Scripting & Interactive UX
 * Includes: Theme Management, Toast Notifications, Debounced Search Suggestions, Dynamic UI Effects
 */

document.addEventListener('DOMContentLoaded', () => {
    initTheme();
    initLocation();
    setupSearchSuggestions();
});

/* ==========================================
   1. Theme Management (Light/Dark Mode)
   ========================================== */
function initTheme() {
    const savedTheme = localStorage.getItem('theme') || 'light';
    document.documentElement.setAttribute('data-theme', savedTheme);
    updateThemeIcon(savedTheme);
}

function toggleDarkMode() {
    const currentTheme = document.documentElement.getAttribute('data-theme');
    const newTheme = currentTheme === 'dark' ? 'light' : 'dark';
    
    document.documentElement.setAttribute('data-theme', newTheme);
    localStorage.setItem('theme', newTheme);
    updateThemeIcon(newTheme);
    
    showToast(`Switched to ${newTheme} mode!`, 'info');
}

function updateThemeIcon(theme) {
    const icon = document.getElementById('darkModeIcon');
    if (!icon) return;
    
    if (theme === 'dark') {
        icon.className = 'bi bi-sun-fill';
        icon.style.color = '#f59e0b';
    } else {
        icon.className = 'bi bi-moon-stars-fill';
        icon.style.color = '';
    }
}

/* ==========================================
   2. Toast Notification Engine
   ========================================== */
function showToast(message, type = 'info') {
    const container = document.getElementById('toastContainer');
    if (!container) return;

    // Toast configuration mapping
    const icons = {
        success: 'bi-check-circle-fill',
        danger: 'bi-exclamation-octagon-fill',
        warning: 'bi-exclamation-triangle-fill',
        info: 'bi-info-circle-fill'
    };

    const toast = document.createElement('div');
    toast.className = `sf-toast sf-toast-${type}`;
    toast.innerHTML = `
        <i class="bi ${icons[type] || icons.info} sf-toast-icon"></i>
        <div class="sf-toast-content fw-semibold">${message}</div>
    `;

    container.appendChild(toast);

    // Auto-remove toast after transition finishes
    setTimeout(() => {
        toast.remove();
    }, 4000);
}

/* ==========================================
   3. Search Suggestions Autocomplete
   ========================================== */
function performNavSearch() {
    const queryEl = document.getElementById('navSearch');
    if (!queryEl) return;
    const q = queryEl.value.trim();
    if (q) {
        window.location.href = 'restaurants.jsp?search=' + encodeURIComponent(q);
    } else {
        window.location.href = 'restaurants.jsp';
    }
}

function setupSearchSuggestions() {
    const input = document.getElementById('navSearch');
    const suggestionsBox = document.getElementById('navSuggestions');
    if (!input || !suggestionsBox) return;

    // Hardcoded dictionary of popular items for premium micro-experience
    const keywords = [
        { name: 'Pizza', icon: '🍕', category: 'Pizza' },
        { name: 'Pepperoni Pizza', icon: '🍕', category: 'Pizza' },
        { name: 'Margherita Pizza', icon: '🍕', category: 'Pizza' },
        { name: 'Biryani', icon: '🍚', category: 'Biryani' },
        { name: 'Chicken Biryani', icon: '🍚', category: 'Biryani' },
        { name: 'Veg Biryani', icon: '🍚', category: 'Biryani' },
        { name: 'Burger', icon: '🍔', category: 'Burger' },
        { name: 'Beef Burger', icon: '🍔', category: 'Burger' },
        { name: 'Butter Chicken', icon: '🍛', category: 'North Indian' },
        { name: 'Paneer Butter Masala', icon: '🍛', category: 'North Indian' },
        { name: 'Noodles', icon: '🍜', category: 'Chinese' },
        { name: 'Dim Sum', icon: '🥟', category: 'Chinese' },
        { name: 'South Indian', icon: '🫓', category: 'South Indian' },
        { name: 'Dosa', icon: '🫓', category: 'South Indian' },
        { name: 'Idli Sambar', icon: '🫓', category: 'South Indian' },
        { name: 'Cheesecake', icon: '🍰', category: 'Desserts' },
        { name: 'Truffle Cake', icon: '🍰', category: 'Desserts' },
        { name: 'Brownie', icon: '🍰', category: 'Desserts' },
        { name: 'Spice Garden', icon: '🏡', type: 'restaurant', id: 1 },
        { name: 'Pizza Palace', icon: '🍕', type: 'restaurant', id: 2 },
        { name: 'Biryani House', icon: '🍚', type: 'restaurant', id: 3 },
        { name: 'Dragon Wok', icon: '🐉', type: 'restaurant', id: 4 },
        { name: 'Burger Barn', icon: '🌾', type: 'restaurant', id: 5 },
        { name: 'South Spice', icon: '🌶️', type: 'restaurant', id: 6 },
        { name: 'The Grill House', icon: '🔥', type: 'restaurant', id: 7 },
        { name: 'Sweet Treats', icon: '🍬', type: 'restaurant', id: 8 }
    ];

    input.addEventListener('input', () => {
        const value = input.value.trim().toLowerCase();
        if (!value) {
            suggestionsBox.style.display = 'none';
            return;
        }

        const filtered = keywords.filter(k => k.name.toLowerCase().includes(value)).slice(0, 5);

        if (filtered.length === 0) {
            suggestionsBox.style.display = 'none';
            return;
        }

        suggestionsBox.innerHTML = '';
        filtered.forEach(item => {
            const el = document.createElement('div');
            el.className = 'suggestion-item';
            el.innerHTML = `
                <span class="suggestion-icon">${item.icon}</span>
                <span>${item.name}</span>
            `;
            el.addEventListener('click', () => {
                if (item.type === 'restaurant') {
                    window.location.href = 'menu.jsp?restaurantId=' + item.id;
                } else {
                    window.location.href = 'restaurants.jsp?search=' + encodeURIComponent(item.name);
                }
            });
            suggestionsBox.appendChild(el);
        });

        suggestionsBox.style.display = 'block';
    });

    // Close suggestions box if click happens outside
    document.addEventListener('click', (e) => {
        if (!input.contains(e.target) && !suggestionsBox.contains(e.target)) {
            suggestionsBox.style.display = 'none';
        }
    });

    input.addEventListener('keypress', (e) => {
        if (e.key === 'Enter') {
            performNavSearch();
        }
    });
}

/* ==========================================
   4. Password Visibility Toggle
   ========================================== */
function togglePassword(inputId, btn) {
    const input = document.getElementById(inputId);
    if (!input) return;
    const icon = btn.querySelector('i');
    if (input.type === 'password') {
        input.type = 'text';
        icon.className = 'bi bi-eye-slash';
    } else {
        input.type = 'password';
        icon.className = 'bi bi-eye';
    }
}

/* ==========================================
   5. Dynamic Location Management
   ========================================== */
function initLocation() {
    const savedLocation = sessionStorage.getItem('userLocation') || 'Bengaluru, Karnataka';
    updateLocationUI(savedLocation);

    // Toggle hero dropdown
    const heroBtn = document.getElementById('heroLocationSelect');
    const heroDropdown = document.getElementById('heroLocationDropdown');
    if (heroBtn && heroDropdown) {
        heroBtn.addEventListener('click', (e) => {
            e.stopPropagation();
            const visible = heroDropdown.style.display === 'block';
            closeAllLocationDropdowns();
            if (!visible) {
                heroDropdown.style.display = 'block';
            }
        });
    }

    // Toggle nav dropdown
    const navBtn = document.getElementById('navLocationSelect');
    const navDropdown = document.getElementById('navLocationDropdown');
    if (navBtn && navDropdown) {
        navBtn.addEventListener('click', (e) => {
            e.stopPropagation();
            const visible = navDropdown.style.display === 'block';
            closeAllLocationDropdowns();
            if (!visible) {
                navDropdown.style.display = 'block';
            }
        });
    }

    // Add listeners on option select
    document.querySelectorAll('.location-option').forEach(opt => {
        opt.addEventListener('click', (e) => {
            e.stopPropagation();
            const selectedLoc = opt.getAttribute('data-value');
            sessionStorage.setItem('userLocation', selectedLoc);
            updateLocationUI(selectedLoc);
            closeAllLocationDropdowns();
            showToast(`Location updated to ${selectedLoc}!`, 'success');
        });
    });

    // Close on outside-click
    document.addEventListener('click', () => {
        closeAllLocationDropdowns();
    });
}

function updateLocationUI(location) {
    const heroText = document.getElementById('heroLocationText');
    if (heroText) heroText.textContent = location;

    const navText = document.getElementById('navLocationText');
    if (navText) navText.textContent = location;
}

function closeAllLocationDropdowns() {
    const heroDropdown = document.getElementById('heroLocationDropdown');
    if (heroDropdown) heroDropdown.style.display = 'none';

    const navDropdown = document.getElementById('navLocationDropdown');
    if (navDropdown) navDropdown.style.display = 'none';
}


