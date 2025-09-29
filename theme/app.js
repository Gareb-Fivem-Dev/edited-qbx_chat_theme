(function () {
    const chatConfig = {
        logo: 'data:image/png;base64,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',
        position: 'left', // left,right,top,bottom
    }

    // Prefix Logo Side //
    const prefixSelect = document.querySelector('.prefix')
    prefixSelect.innerHTML = ""; // reset
    prefixSelect.style.backgroundImage = `url(${chatConfig.logo})`;

    // Chat Position //
    const chat = document.querySelector('.chat-input')
    chat.style.top = 'inherit';
    chat.style.right = 'inherit';
    chat.style.bottom = 'inherit';
    chat.style.left = 'inherit';

    switch (chatConfig.position) {
        case 'left':
            chat.style.top = '30%';
            chat.style.left = '0.8%';
            break;
        case 'right':
            chat.style.top = '30%';
            chat.style.right = '0.8%';
            break;
        case 'top':
            chat.style.top = '5%';
            chat.style.left = '40%';
            break;
        case 'bottom':
            chat.style.bottom = '5%';
            chat.style.left = '40%';
            break;
        default:
            console.log('Invalid position');
    }


})();