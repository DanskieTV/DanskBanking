let isOpen = false;
let currentBalance = 0;
let activeModal = null;

// Create a transactions array to track existing transactions
let transactions = [];

// Initialize Event Listeners
document.addEventListener('DOMContentLoaded', function() {
    // Menu Items
    document.querySelectorAll('.menu-item').forEach(item => {
        item.addEventListener('click', function() {
            if (this.id === 'close-button') {
                closeUI();
                return;
            }
            
            const pageId = this.dataset.page;
            if (pageId) {
                showPage(pageId);
                document.querySelectorAll('.menu-item').forEach(i => i.classList.remove('active'));
                this.classList.add('active');
            }
        });
    });

    // Action Buttons
    document.getElementById('deposit-btn').addEventListener('click', () => openModal('Deposit'));
    document.getElementById('withdraw-btn').addEventListener('click', () => openModal('Withdraw'));
    document.getElementById('transfer-btn').addEventListener('click', () => openModal('Transfer'));

    // Modal Buttons
    document.getElementById('modal-cancel').addEventListener('click', closeModal);
    document.getElementById('modal-confirm').addEventListener('click', handleModalConfirm);

    // Settings handlers
    document.getElementById('change-pin').addEventListener('click', function() {
        openModal('Change PIN', true);
    });

    document.getElementById('notifications-toggle').addEventListener('change', function() {
        fetch(`https://${GetParentResourceName()}/updateSettings`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                notifications: this.checked
            })
        });
    });

    // Transaction filters
    document.getElementById('transaction-type').addEventListener('change', filterTransactions);
    document.getElementById('date-filter').addEventListener('change', filterTransactions);
});

// NUI Message Handler
window.addEventListener('message', function(event) {
    const data = event.data;

    switch(data.action) {
        case 'openBank':
            transactions = []; // Reset transactions array
            isOpen = true;
            document.body.style.display = 'block';
            if (data.data.logo) {
                document.getElementById('bank-logo').src = data.data.logo;
            }
            if (data.data.balance !== undefined) {
                updateBalance(data.data.balance);
            }
            // Clear existing transactions
            const transactionsList = document.getElementById('transactions-list');
            if (transactionsList) {
                transactionsList.innerHTML = '<div class="no-transactions">No recent transactions</div>';
            }
            break;
            
        case 'loadTransactions':
            if (Array.isArray(data.data)) {
                const transactionsList = document.getElementById('transactions-list');
                if (transactionsList) {
                    transactionsList.innerHTML = ''; // Clear existing
                    data.data.forEach(transaction => {
                        addTransaction(transaction);
                    });
                }
            }
            break;
            
        case 'updateBalance':
            if (data.data !== undefined) {
                updateBalance(data.data);
            }
            break;
            
        case 'updateTransactions':
            if (data.data) {
                addTransaction(data.data);
            }
            break;
    }
});

// UI Functions
function updateBalance(balance) {
    const balanceElement = document.getElementById('balance');
    if (balanceElement) {
        balanceElement.textContent = new Intl.NumberFormat('en-US', {
            style: 'currency',
            currency: 'USD',
            minimumFractionDigits: 2
        }).format(balance);
    }
}

function updateTransactions(transactions) {
    const container = document.getElementById('transactions-list');
    container.innerHTML = '';
    
    if (!transactions || transactions.length === 0) {
        container.innerHTML = '<div class="no-transactions">No recent transactions</div>';
        return;
    }
    
    transactions.forEach(transaction => {
        const item = document.createElement('div');
        item.className = 'transaction-item';
        item.innerHTML = `
            <div class="transaction-info">
                <span class="transaction-type">${transaction.type}</span>
                <span class="transaction-date">${formatDate(transaction.date)}</span>
            </div>
            <span class="transaction-amount ${transaction.amount >= 0 ? 'positive' : 'negative'}">
                ${transaction.amount >= 0 ? '+' : ''}${formatMoney(transaction.amount)}
            </span>
        `;
        container.appendChild(item);
    });
}

// Modal Functions
function openModal(type) {
    const modal = document.getElementById('modal');
    const modalTitle = document.getElementById('modal-title');
    const modalContent = document.querySelector('.modal-content');
    
    modalTitle.textContent = type;
    activeModal = type;
    
    // Clear previous inputs
    modalContent.innerHTML = `
        <h2 id="modal-title">${type}</h2>
        <input type="number" id="amount" placeholder="Enter amount">
        <input type="text" id="description" placeholder="Description (optional)">
        ${type === 'Transfer' ? '<input type="number" id="transfer-target" placeholder="Player ID">' : ''}
        <div class="modal-buttons">
            <button id="modal-confirm">Confirm</button>
            <button id="modal-cancel">Cancel</button>
        </div>
    `;
    
    // Reattach event listeners
    document.getElementById('modal-confirm').addEventListener('click', handleModalConfirm);
    document.getElementById('modal-cancel').addEventListener('click', closeModal);
    
    modal.style.display = 'flex';
}

function closeModal() {
    document.getElementById('modal').style.display = 'none';
    activeModal = null;
}

function handleModalConfirm() {
    const amount = parseFloat(document.getElementById('amount').value);
    const description = document.getElementById('description').value;
    
    if (!amount || isNaN(amount) || amount <= 0) {
        return;
    }

    switch(activeModal) {
        case 'Deposit':
            fetch(`https://${GetParentResourceName()}/deposit`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ amount, description })
            });
            break;
            
        case 'Withdraw':
            fetch(`https://${GetParentResourceName()}/withdraw`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ amount, description })
            });
            break;
            
        case 'Transfer':
            const targetId = document.getElementById('transfer-target')?.value;
            fetch(`https://${GetParentResourceName()}/transfer`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ amount, description, target: targetId })
            });
            break;
    }
    
    closeModal();
}

// Utility Functions
function formatMoney(amount) {
    return new Intl.NumberFormat('en-US', {
        style: 'currency',
        currency: 'USD'
    }).format(amount);
}

function formatDate(date) {
    return new Date(date).toLocaleDateString();
}

function closeUI() {
    fetch(`https://${GetParentResourceName()}/closeBank`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    });
    document.body.style.display = 'none';
    isOpen = false;
}

// Key binding for ESC
document.addEventListener('keydown', function(event) {
    if (event.key === 'Escape' && isOpen) {
        closeUI();
    }
});

// Page Navigation
function showPage(pageId) {
    document.querySelectorAll('.page').forEach(page => {
        page.style.display = 'none';
    });
    document.getElementById(`${pageId}-page`).style.display = 'block';
}

// Settings handlers
document.getElementById('change-pin').addEventListener('click', function() {
    openModal('Change PIN', true);
});

document.getElementById('notifications-toggle').addEventListener('change', function() {
    fetch(`https://${GetParentResourceName()}/updateSettings`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
            notifications: this.checked
        })
    });
});

// Transaction filters
document.getElementById('transaction-type').addEventListener('change', filterTransactions);
document.getElementById('date-filter').addEventListener('change', filterTransactions);

function filterTransactions() {
    const type = document.getElementById('transaction-type').value;
    const date = document.getElementById('date-filter').value;
    
    fetch(`https://${GetParentResourceName()}/getFilteredTransactions`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ type, date })
    });
}

// Function to add new transaction to the list
function addTransaction(transaction) {
    const transactionsList = document.getElementById('transactions-list');
    if (!transactionsList) return;

    // Create unique ID for transaction based on type, amount, and timestamp
    const transactionId = `${transaction.type}-${transaction.amount}-${transaction.date}`;
    
    // Check if transaction already exists
    if (transactions.includes(transactionId)) {
        return; // Skip if already exists
    }
    
    // Add to tracking array
    transactions.push(transactionId);
    
    // Limit array size to prevent memory issues
    if (transactions.length > 50) {
        transactions.shift();
    }

    // Clear "No recent transactions" if it exists
    const noTransactions = transactionsList.querySelector('.no-transactions');
    if (noTransactions) {
        noTransactions.remove();
    }

    const transactionElement = document.createElement('div');
    transactionElement.className = 'transaction-item';
    
    const amountClass = transaction.amount >= 0 ? 'positive' : 'negative';
    const amountFormatted = new Intl.NumberFormat('en-US', {
        style: 'currency',
        currency: 'USD',
        minimumFractionDigits: 2
    }).format(Math.abs(transaction.amount));
    
    const prefix = transaction.amount >= 0 ? '+' : '-';
    
    transactionElement.innerHTML = `
        <div class="transaction-info">
            <span class="transaction-type">${transaction.type}</span>
            <span class="transaction-date">${formatDate(transaction.date)}</span>
        </div>
        <span class="transaction-amount ${amountClass}">
            ${prefix}${amountFormatted}
        </span>
    `;

    // Keep only the last 8 transactions visible
    const existingTransactions = transactionsList.children;
    if (existingTransactions.length >= 8) {
        transactionsList.removeChild(transactionsList.lastChild);
    }

    // Insert new transaction at the top
    transactionsList.insertBefore(transactionElement, transactionsList.firstChild);
}

// Add a helper function to format dates
function formatDate(dateString) {
    const date = new Date(dateString);
    return date.toLocaleString('en-US', {
        year: 'numeric',
        month: '2-digit',
        day: '2-digit',
        hour: '2-digit',
        minute: '2-digit',
        second: '2-digit',
        hour12: false
    });
}

// Add new UI components for loans and joint accounts
function showLoanApplication() {
    const modal = document.getElementById('loan-modal');
    modal.innerHTML = `
        <div class="loan-application">
            <h2>Loan Application</h2>
            <div class="loan-info">
                <label>Amount Requested:</label>
                <input type="number" id="loan-amount" min="1000">
                <label>Purpose:</label>
                <select id="loan-purpose">
                    <option value="personal">Personal Loan</option>
                    <option value="business">Business Loan</option>
                    <option value="vehicle">Vehicle Loan</option>
                </select>
                <button id="submit-loan">Apply for Loan</button>
            </div>
        </div>
    `;
    
    document.getElementById('submit-loan').addEventListener('click', submitLoanApplication);
}

function showJointAccountManagement() {
    const modal = document.getElementById('joint-account-modal');
    modal.innerHTML = `
        <div class="joint-account">
            <h2>Joint Account Management</h2>
            <div class="member-list">
                <!-- Members will be populated here -->
            </div>
            <button id="add-member">Add Member</button>
        </div>
    `;
    
    fetchJointAccountMembers();
}

// Add handlers for the new features
document.getElementById('create-joint-account').addEventListener('click', () => {
    fetch(`https://${GetParentResourceName()}/createJointAccount`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    });
}); 