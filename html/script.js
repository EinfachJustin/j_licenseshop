document.addEventListener('DOMContentLoaded', function () {
    const playersList = document.getElementById('players');
    const licensesList = document.getElementById('licenses');
    const closeButton = document.getElementById('close-button');

    let selectedPlayerId = null;
    let allLicenses = []; // Store all available licenses
    let currentPlayerLicenses = []; // Store licenses of the currently selected player

    window.addEventListener('message', function (event) {
        const item = event.data;
        if (item.type === 'openMenu') {
            document.body.style.display = 'flex';
            updatePlayers(item.players);
            allLicenses = item.licenses; // Store all licenses
            updateLicenses(allLicenses); // Display all licenses initially
            selectedPlayerId = null; // Reset selected player
            currentPlayerLicenses = []; // Reset player licenses
            // Clear selected player in UI
            document.querySelectorAll('.player').forEach(p => p.classList.remove('selected'));
        } else if (item.type === 'updatePlayerLicenses') {
            currentPlayerLicenses = item.licenses;
            updateLicenses(allLicenses);
        } else {
            document.body.style.display = 'none';
        }
    });

    function updatePlayers(players) {
        playersList.innerHTML = '';
        if (players.length > 0) {
            players.forEach(player => {
                const li = document.createElement('li');
                li.className = 'player';
                li.textContent = `${player.name} (ID: ${player.id})`;
                li.dataset.id = player.id;
                li.addEventListener('click', () => {
                    selectedPlayerId = player.id;
                    document.querySelectorAll('.player').forEach(p => p.classList.remove('selected'));
                    li.classList.add('selected');
                    post('getPlayerLicenses', { playerId: selectedPlayerId });
                });
                playersList.appendChild(li);
            });
        } else {
            playersList.innerHTML = '<li>Keine Spieler in der Nähe</li>';
        }
    }

    function updateLicenses(licenses) {
        licensesList.innerHTML = '';
        licenses.forEach(license => {
            const li = document.createElement('li');
            li.className = 'license';

            const licenseInfo = document.createElement('div');
            licenseInfo.className = 'license-info';

            const licenseLabel = document.createElement('span');
            licenseLabel.textContent = license.Label;
            licenseInfo.appendChild(licenseLabel);

            const statusSpan = document.createElement('span');
            statusSpan.className = 'license-status';
            if (currentPlayerLicenses.includes(license.Type)) {
                statusSpan.textContent = 'Besitzt';
                statusSpan.classList.add('has-license');
            } else {
                statusSpan.textContent = 'Besitzt nicht';
                statusSpan.classList.add('no-license');
            }
            licenseInfo.appendChild(statusSpan);

            li.appendChild(licenseInfo);

            const actions = document.createElement('div');
            actions.className = 'license-actions';

            const giveBtn = document.createElement('button');
            giveBtn.textContent = 'Erteilen';
            giveBtn.className = 'btn give-btn';
            giveBtn.addEventListener('click', (e) => {
                e.stopPropagation();
                if (selectedPlayerId) {
                    post('giveLicense', { playerId: selectedPlayerId, licenseType: license.Type });
                } else {
                }
            });

            const revokeBtn = document.createElement('button');
            revokeBtn.textContent = 'Entziehen';
            revokeBtn.className = 'btn revoke-btn';
            revokeBtn.addEventListener('click', (e) => {
                e.stopPropagation();
                if (selectedPlayerId) {
                    post('revokeLicense', { playerId: selectedPlayerId, licenseType: license.Type });
                } else {
                }
            });

            actions.appendChild(giveBtn);
            actions.appendChild(revokeBtn);
            li.appendChild(actions);
            licensesList.appendChild(li);
        });
    }

    closeButton.addEventListener('click', () => {
        document.body.style.display = 'none'; // Hide the menu
        post('closeMenu', {});
    });

    document.addEventListener('keydown', function (e) {
        if (e.key === 'Escape') {
            document.body.style.display = 'none'; // Hide the menu
            post('closeMenu', {});
        }
    });

    function post(eventName, data) {
        fetch(`https://j_licenseshop/${eventName}`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json; charset=UTF-8',
            },
            body: JSON.stringify(data || {}),
        }).then(resp => resp.json()).then(resp => {
            // console.log(resp)
        });
    }

    // For development in browser
    // window.postMessage({ type: 'openMenu', players: [{id: 1, name: 'Test Player'}], licenses: [{Type: 'weapon', Label: 'Waffenschein'}, {Type: 'drive', Label: 'Führerschein'}]}, '*');
});
