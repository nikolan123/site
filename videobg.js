(function () {
    const videos = [
        { src: '/resources/backgrounds/act1.webm', colors: { 
            '--link-row-hover-bg': 'rgba(35, 42, 50, 0.1)', 
            '--a-color': 'rgb(191, 176, 128)', 
            '--details-background': 'rgba(35, 42, 50, 0.257)' 
        }},
        { src: '/resources/backgrounds/act2.webm', colors: { 
            '--link-row-hover-bg': 'rgba(151, 121, 64, 0.1)', 
            '--a-color': 'rgb(223, 187, 120)', 
            '--details-background': 'rgba(151, 115, 64, 0.1)' 
        }},
        { src: '/resources/backgrounds/act3.webm', colors: { 
            '--link-row-hover-bg': 'rgba(64, 78, 151, 0.1)', 
            '--a-color': 'rgba(124, 137, 197, 1)', 
            '--details-background': 'rgba(57, 68, 117, 0.1)' 
        }},
    ];

    const randomIndex = Math.floor(Math.random() * videos.length);
    const chosen = videos[randomIndex];

    for (const [varName, value] of Object.entries(chosen.colors)) {
        document.documentElement.style.setProperty(varName, value);
    }

    const video = document.createElement('video');
    video.src = chosen.src;
    video.autoplay = true;
    video.muted = true;
    video.loop = true;
    video.playsInline = true;
    video.style.position = 'fixed';
    video.style.top = '0';
    video.style.left = '0';
    video.style.width = '100%';
    video.style.height = '100%';
    video.style.objectFit = 'cover';
    video.style.zIndex = '-2';
    video.style.filter = 'blur(8px) brightness(0.5)';

    document.body.appendChild(video);

    video.addEventListener('loadedmetadata', () => {
        video.currentTime = Math.random() * video.duration;
        video.play();
    });
})();
