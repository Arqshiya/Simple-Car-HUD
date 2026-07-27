window.addEventListener('message', function (event) {
    const data = event.data;
    if (!data || !data.action) return;

    switch (data.action) {
        case 'toggleCarHud':
            toggleCarHud(data.data);
            break;
        case 'updateCarHud':
            updateCarHud(data.data);
            break;
        case 'updateHudFuel':
            updateHudFuel(data.data);
            break;
        case 'handleEngine':
            handleEngine(data.data);
            break;
        case 'handleLock':
            handleLock(data.data);
            break;
        case 'handleBelt':
            handleBelt(data.data);
            break;
            
        case 'updateEngineHealth':
            updateEngineHealth(data.data);
            break;
    }
});

function toggleCarHud(data) {
    const hud = document.getElementById('car-hud');
    if (!hud) return;

    if (data && data.show) {
        hud.classList.remove('hidden');
    } else {
        hud.classList.add('hidden');
    }
}

function updateCarHud(data) {
    if (!data) return;

    // سرعت
    const speedEl = document.getElementById('speed');
    if (speedEl) {
        const spd = Math.round(Number(data.speed) || 0);
        speedEl.textContent = spd;
    }

    // دنده
    const gearEl = document.getElementById('gear');
    if (gearEl) {
        let gear = data.gear;

        if (gear === 0 || gear === '0') {
            gear = 'R'; 
        } else if (gear === null || gear === undefined || gear === '') {
            gear = 'N'; 
        }

        gearEl.textContent = gear;
    }


    if (typeof data.fuel !== 'undefined') {
        updateHudFuel({ fuel: data.fuel });
    }

    if (typeof data.engineHealth !== 'undefined') {
        updateEngineHealth({ health: data.engineHealth });
    }

    if (typeof data.engineOn !== 'undefined') {
        handleEngine({ state: data.engineOn, health: data.engineHealth });
    }

    if (typeof data.locked !== 'undefined') {
        handleLock({ state: data.locked });
    }

    if (typeof data.seatbelt !== 'undefined') {
        handleBelt({ state: data.seatbelt });
    }
}

/* سوخت */
function updateHudFuel(data) {
    if (!data) return;

    const fuelValueEl = document.getElementById('fuel-value');
    const fuelBox = document.getElementById('fuel');

    const fuel = clampPercent(data.fuel);

    if (fuelValueEl) {
        fuelValueEl.textContent = fuel;
        fuelValueEl.classList.remove('critical-text');
    }
    if (fuelBox) {
        fuelBox.classList.remove('critical-border');
    }

    if (fuel < 40) {
        if (fuelValueEl) fuelValueEl.classList.add('critical-text');
        if (fuelBox) fuelBox.classList.add('critical-border');
    }
}

/* سلامت موتور */
function updateEngineHealth(health) {
    const engineBar = document.getElementById('engine-bar');
    const engineValue = document.getElementById('engine-value');
    const engineIconValue = document.getElementById('engine-icon-value');
  let rawValue = (typeof healthData === 'object' && healthData !== null) ? healthData.health : healthData;
    const val = parseInt(health, 10);
    const safeVal = isNaN(val) ? 0 : Math.max(0, Math.min(val, 100));

    if (engineBar) {
        engineBar.style.width = safeVal + '%';

        engineBar.classList.remove('low-bar');
        if (safeVal <= 40) {
            engineBar.classList.add('low-bar');
        }
    }

    if (engineValue) {
        engineValue.textContent = safeVal.toString();
        engineValue.classList.remove('low-value');
        if (safeVal <= 40) {
            engineValue.classList.add('low-value');
        }
    }

    if (engineIconValue) {
        engineIconValue.textContent = safeVal.toString();
    }
}


function handleEngine(data) {
    const engineIcon = document.getElementById('engine');
    if (!engineIcon) return;

    const isOn = !!(data && data.state);

    engineIcon.classList.remove('status-on', 'status-off');
    engineIcon.classList.add(isOn ? 'status-on' : 'status-off');

    if (data && typeof data.health !== 'undefined') {
        updateEngineHealth({ health: data.health });
    }
}


function handleLock(data) {
    const lockIcon = document.getElementById('lock');
    if (!lockIcon) return;

    const locked = !!(data && data.state);

    lockIcon.classList.remove('status-on', 'status-off');
    lockIcon.classList.add(locked ? 'status-on' : 'status-off');
}


function handleBelt(data) {
    const beltIcon = document.getElementById('seatbelt');
    if (!beltIcon) return;

    const buckled = !!(data && data.state);

    beltIcon.classList.remove('status-on', 'status-off');
    beltIcon.classList.add(buckled ? 'status-on' : 'status-off');
}


function clampPercent(value) {
    let v = Number(value);
    if (isNaN(v)) v = 0;
    if (v < 0) v = 0;
    if (v > 100) v = 100;
    return Math.round(v);
}
