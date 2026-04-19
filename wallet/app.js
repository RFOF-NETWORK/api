// wallet/app.js
// RFOF‑NETWORK · WALLET — UI-Logik (rein frontend, keine echten Transaktionen)

(() => {
  let currentTokenName = null;

  document.addEventListener('DOMContentLoaded', () => {
    initGUCI();
    initStatusBar();
    initMasterRole();
    initLpVisibility();
    initCoinTiles();
    initEuroActions();
    initDexButton();
    initLaunchpad();
    initMining();
  });

  // 1. GUCI-Persistenz
  function initGUCI() {
    const guci = localStorage.getItem('globalClientID');
    const guciLink = document.querySelector('.guci-link');
    if (guci && guciLink) {
      guciLink.textContent = guci;
      guciLink.href = '../viewer/index.html?guci=' + encodeURIComponent(guci);
    }
  }

  // 2. Status-Bar (XP/JOUL)
  function initStatusBar() {
    const xp = localStorage.getItem('xp') || '80';
    const joule = localStorage.getItem('joule') || '0';
    const statusBar = document.querySelector('.status-bar');
    if (!statusBar) return;
    const xpNode = statusBar.querySelector('div:nth-child(1) b');
    if (xpNode) xpNode.textContent = xp + '/' + joule;
  }

  // 3. MASTER-Rolle
  function initMasterRole() {
    const isMaster = localStorage.getItem('rfof_user') === 'RFOF-NETWORK';

    const masterBox = document.querySelector('.master-admin-box');
    if (masterBox) {
      masterBox.style.display = isMaster ? 'block' : 'none';
    }

    document.querySelectorAll('.master-only').forEach(el => {
      el.style.display = isMaster ? '' : 'none';
    });
  }

  // 4. LP-Token Sichtbarkeit
  function initLpVisibility() {
    const phoenixLp = parseFloat(localStorage.getItem('balance_phoenix_lp') || '0');
    const rfofGoldLp = parseFloat(localStorage.getItem('balance_rfof_gold_lp') || '0');
    const bip = parseFloat(localStorage.getItem('balance_bip') || '0');

    document.querySelectorAll('.coin-tile[data-lp="true"]').forEach(tile => {
      const nameEl = tile.querySelector('.coin-name');
      if (!nameEl) return;
      const name = nameEl.textContent.trim();

      if (name === 'Phoenix LP' && phoenixLp === 0) tile.style.display = 'none';
      if (name === 'RFOF/GOLD LP' && rfofGoldLp === 0) tile.style.display = 'none';
      if (name === 'BIP (Ability API LP)' && bip === 0) tile.style.display = 'none';
    });
  }

  // 5. Balance-Kacheln → Detail-View
  function initCoinTiles() {
    document.querySelectorAll('.coin-tile').forEach(tile => {
      // Inline onclick existiert bereits, hier nur Fallback
      if (!tile.getAttribute('onclick')) {
        const nameEl = tile.querySelector('.coin-name');
        if (!nameEl) return;
        const tokenName = nameEl.textContent.trim();
        tile.addEventListener('click', () => openDetail(tokenName));
      }
    });
  }

  // 6. Euro-Box Aktionen
  function initEuroActions() {
    // Inline onclicks sind in der HTML gesetzt, hier nur Fallback, falls nötig
    const map = {
      'Send': openSend,
      'Receive': openReceive,
      'Swap (Bridge)': openSwap
    };
    document.querySelectorAll('.euro-balance-actions .btn-chip-primary').forEach(btn => {
      if (!btn.getAttribute('onclick')) {
        const label = btn.textContent.trim();
        if (map[label]) {
          btn.addEventListener('click', map[label]);
        }
      }
    });
  }

  // 7. DEX-Button
  function initDexButton() {
    const dexBtn = document.querySelector('.btn-dex');
    if (dexBtn && !dexBtn.getAttribute('onclick')) {
      dexBtn.addEventListener('click', () => openDEX(currentTokenName));
    }
  }

  // 8. Launchpad
  function initLaunchpad() {
    const lpBtn = document.querySelector('.btn-outline');
    if (lpBtn && !lpBtn.getAttribute('onclick')) {
      lpBtn.addEventListener('click', openLaunchpad);
    }
  }

  // 9. Mining
  function initMining() {
    const miningBtn = document.querySelector('.btn-mining');
    if (miningBtn && !miningBtn.getAttribute('onclick')) {
      miningBtn.addEventListener('click', startMining);
    }
  }

  // --- Detail-View / Charts ---

  window.openDetail = function(tokenName) {
    currentTokenName = tokenName;
    const detail = document.getElementById('detail-view');
    if (!detail) return;

    const titleEl = detail.querySelector('.detail-title');
    const metaEl = detail.querySelector('.detail-meta');
    const perfEl = detail.querySelector('.detail-performance');

    if (titleEl) titleEl.textContent = tokenName + ' PERFORMANCE';

    if (metaEl) {
      metaEl.innerHTML = 'Balance: 0.0000&nbsp;|&nbsp;Steigerung: 0,2% pro Interaktion · 0,4% Roundtrip (Basis‑Token)';
    }

    if (perfEl) {
      perfEl.innerHTML =
        'Basis‑Token (RFOF, GOLD, Phoenix, G‑Phoenix): 0,2% pro Interaktion · 0,4% Roundtrip<br />' +
        'LP‑Token (RFOF/GOLD LP, Phoenix LP): 0,4% pro Interaktion · 0,8% Roundtrip<br />' +
        'Master‑Token (BIP): 0,8% pro Interaktion · 1,6% Roundtrip';
    }

    switchChartMode('standard');

    detail.style.display = 'block';
    detail.scrollIntoView({ behavior: 'smooth' });
  };

  window.closeDetail = function() {
    const detail = document.getElementById('detail-view');
    if (!detail) return;
    detail.style.display = 'none';
  };

  window.switchChartMode = function(mode) {
    const standardTab = document.querySelector('.chart-tab:nth-child(1)');
    const mechaTab = document.querySelector('.chart-tab:nth-child(2)');
    const standardChart = document.getElementById('chart-standard');
    const mechaChart = document.getElementById('chart-mecha');

    if (!standardTab || !mechaTab || !standardChart || !mechaChart) return;

    standardTab.classList.remove('chart-tab-active');
    mechaTab.classList.remove('chart-tab-active');

    if (mode === 'standard') {
      standardTab.classList.add('chart-tab-active');
      standardChart.style.display = 'flex';
      mechaChart.style.display = 'none';
    } else {
      mechaTab.classList.add('chart-tab-active');
      standardChart.style.display = 'none';
      mechaChart.style.display = 'flex';
    }
  };

  // --- Aktionen Euro-Box ---

  window.openSend = function() {
    addHistoryEntry('SEND', '10 RFOF an GUCI-XYZ...');
    console.log('SEND UI geöffnet (Simulation)');
  };

  window.openReceive = function() {
    addHistoryEntry('RECEIVE', 'Adresse für Empfang angezeigt...');
    console.log('RECEIVE UI geöffnet (Simulation)');
  };

  window.openSwap = function() {
    addHistoryEntry('SWAP', '5 GOLD → 2 ECCU (BRIDGE-Routing simuliert)...');
    console.log('SWAP/BRIDGE UI geöffnet (Simulation)');
  };

  window.openDeposit = function() {
    addHistoryEntry('DEPOSIT', 'Einzahlung (EUR/BTC/TON) vorbereitet...');
    console.log('DEPOSIT UI geöffnet (Simulation)');
  };

  window.openWithdraw = function() {
    addHistoryEntry('WITHDRAW', 'Auszahlung (EUR/BTC/TON) vorbereitet...');
    console.log('WITHDRAW UI geöffnet (Simulation)');
  };

  // --- DEX / Launchpad / Mining ---

  window.openDEX = function(tokenName) {
    const name = tokenName || 'Unbekannter Token';
    addHistoryEntry('DEX', 'Zum DEX für ' + name);
    console.log('DEX geöffnet für', name, '(Simulation)');
  };

  window.openLaunchpad = function() {
    addHistoryEntry('LAUNCHPAD', 'Meme-Token Launchpad geöffnet...');
    console.log('Launchpad geöffnet (Simulation)');
  };

  window.startMining = function() {
    const statusPill = document.querySelector('.mining-pill-active');
    if (statusPill) statusPill.textContent = 'Status: ACTIVE';

    const joule = parseFloat(localStorage.getItem('joule') || '0') + 5;
    localStorage.setItem('joule', String(joule));
    initStatusBar();

    addHistoryEntry('MINING', '+5 Joule quantisiert...');
    console.log('Mining gestartet (Simulation)');
  };

  // --- Historie ---

  function addHistoryEntry(type, details) {
    const lists = document.querySelectorAll('.history-list');
    if (!lists.length) return;
    const walletHistory = lists[lists.length - 1]; // unterste Historie (Wallet)

    const now = new Date();
    const hh = String(now.getHours()).padStart(2, '0');
    const mm = String(now.getMinutes()).padStart(2, '0');
    const ss = String(now.getSeconds()).padStart(2, '0');

    const txMatch = details.match(/0x[0-9a-fA-F]+/);
    const txId = txMatch ? txMatch[0] : '0x' + now.getTime().toString(16);

    const div = document.createElement('div');
    div.className = 'history-entry';
    div.innerHTML =
      '[' + hh + ':' + mm + ':' + ss + '] ' +
      '<a class="hash-link" href="../viewer/index.html?tx=' + encodeURIComponent(txId) + '">' +
      type + ': ' + details +
      '</a>';

    walletHistory.appendChild(div);
  }
})();
