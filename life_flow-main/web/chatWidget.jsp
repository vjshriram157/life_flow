<div id="ai-chat-container" style="position: fixed; bottom: 30px; right: 30px; z-index: 9999;">
    <!-- Launcher -->
    <div id="chat-launcher" style="width: 60px; height: 60px; background: linear-gradient(135deg, #e11d48, #991b1b); border-radius: 50%; display: flex; justify-content: center; align-items: center; color: white; cursor: pointer; box-shadow: 0 10px 30px rgba(225, 29, 72, 0.4); border: 2px solid rgba(255,255,255,0.2); transition: all 0.3s ease;">
        <i class="fa-solid fa-robot fs-4"></i>
    </div>

    <!-- Chat Window -->
    <div id="chat-window" style="display: none; width: 350px; height: 450px; background: #0f172a; border: 1px solid rgba(255,255,255,0.1); border-radius: 20px; box-shadow: 0 20px 50px rgba(0,0,0,0.5); flex-direction: column; overflow: hidden; opacity: 0; transform: translateY(20px); transition: all 0.4s cubic-bezier(0.18, 0.89, 0.32, 1.28);">
        <!-- Header -->
        <div style="background: rgba(255,255,255,0.03); padding: 20px; border-bottom: 1px solid rgba(255,255,255,0.05); display: flex; justify-content: space-between; align-items: center;">
            <div style="display: flex; align-items: center; gap: 12px;">
                <div style="width: 10px; height: 10px; background: #10b981; border-radius: 50%; box-shadow: 0 0 10px #10b981;"></div>
                <span style="color: white; font-weight: 700; font-size: 0.9rem;">LifeFlow AI Assistant</span>
            </div>
            <i class="fa-solid fa-xmark text-white-50" style="cursor: pointer;" id="close-chat"></i>
        </div>
        
        <!-- Messages Area -->
        <div id="chat-messages" style="flex: 1; padding: 20px; overflow-y: auto; display: flex; flex-direction: column; gap: 15px;">
            <div style="background: rgba(255,255,255,0.05); color: #cbd5e1; padding: 12px 16px; border-radius: 15px 15px 15px 0; font-size: 0.85rem; max-width: 85%;">
                Welcome Hero! I'm your health-assistant. Ask me anything about donation eligibility or recovery.
            </div>
        </div>

        <!-- Input Area -->
        <div style="padding: 15px; background: rgba(255,255,255,0.03); border-top: 1px solid rgba(255,255,255,0.05); display: flex; gap: 10px; align-items: center;">
            <button id="mic-btn" style="background: transparent; border: 1px solid rgba(255,255,255,0.1); width: 40px; height: 40px; border-radius: 10px; color: #cbd5e1; cursor: pointer; transition: all 0.3s ease;">
                <i class="fa-solid fa-microphone"></i>
            </button>
            <input type="text" id="chat-input" placeholder="Type or speak..." style="flex: 1; background: rgba(255,255,255,0.05); border: 1px solid rgba(255,255,255,0.1); border-radius: 10px; padding: 10px 15px; color: white; font-size: 0.85rem; outline: none;">
            <button id="send-chat" style="background: #e11d48; border: none; width: 40px; height: 40px; border-radius: 10px; color: white; cursor: pointer;">
                <i class="fa-solid fa-paper-plane"></i>
            </button>
        </div>
    </div>
</div>

<script>
document.addEventListener('DOMContentLoaded', function() {
    const launcher = document.getElementById('chat-launcher');
    const chatWin = document.getElementById('chat-window');
    const closeBtn = document.getElementById('close-chat');
    const sendBtn = document.getElementById('send-chat');
    const input = document.getElementById('chat-input');
    const messagesArea = document.getElementById('chat-messages');

    launcher.onclick = () => {
        chatWin.style.display = 'flex';
        setTimeout(() => {
            chatWin.style.opacity = '1';
            chatWin.style.transform = 'translateY(0)';
        }, 10);
        launcher.style.transform = 'scale(0) rotate(90deg)';
    };

    closeBtn.onclick = () => {
        chatWin.style.opacity = '0';
        chatWin.style.transform = 'translateY(20px)';
        setTimeout(() => {
            chatWin.style.display = 'none';
            launcher.style.transform = 'scale(1) rotate(0deg)';
        }, 400);
    };

    function addMessage(text, isUser = false) {
        const div = document.createElement('div');
        div.style.padding = '12px 16px';
        div.style.borderRadius = isUser ? '15px 15px 0 15px' : '15px 15px 15px 0';
        div.style.fontSize = '0.85rem';
        div.style.maxWidth = '85%';
        div.style.alignSelf = isUser ? 'flex-end' : 'flex-start';
        div.style.background = isUser ? '#e11d48' : 'rgba(255,255,255,0.05)';
        div.style.color = isUser ? 'white' : '#cbd5e1';
        div.innerText = text;
        messagesArea.appendChild(div);
        messagesArea.scrollTop = messagesArea.scrollHeight;
    }

    sendBtn.onclick = async () => {
        const msg = input.value.trim();
        if(!msg) return;
        
        input.value = '';
        addMessage(msg, true);

        try {
            const res = await fetch('<%=request.getContextPath()%>/api/chat', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: 'message=' + encodeURIComponent(msg)
            });
            const data = await res.json();
            setTimeout(() => addMessage(data.reply), 500);
        } catch(e) {
            addMessage("AI relay offline. Please check back soon.");
        }
    };

    input.onkeypress = (e) => { if(e.key === 'Enter') sendBtn.click(); };

    // --- VOICE INTELLIGENCE ---
    const micBtn = document.getElementById('mic-btn');
    const SpeechRecognition = window.SpeechRecognition || window.webkitSpeechRecognition;
    let recognition;

    if (SpeechRecognition) {
        recognition = new SpeechRecognition();
        recognition.continuous = false;
        recognition.lang = 'en-US';

        recognition.onstart = () => {
            micBtn.classList.add('recording');
            micBtn.innerHTML = '<i class="fa-solid fa-circle-dot fa-fade text-danger"></i>';
            input.placeholder = "Listening...";
        };

        recognition.onend = () => {
            micBtn.classList.remove('recording');
            micBtn.innerHTML = '<i class="fa-solid fa-microphone"></i>';
            input.placeholder = "Type or speak...";
        };

        recognition.onresult = (event) => {
            const transcript = event.results[0][0].transcript;
            input.value = transcript;
            setTimeout(() => sendBtn.click(), 500);
        };
    }

    micBtn.onclick = () => {
        if (!SpeechRecognition) {
            addMessage("Voice recognition is not supported in this browser. Please use Chrome or Edge on localhost/HTTPS.", false);
            return;
        }
        if (micBtn.classList.contains('recording')) {
            recognition.stop();
        } else {
            recognition.start();
        }
    };

    function speakReply(text) {
        if (!window.speechSynthesis) return;
        const cleanText = text.replace(/[^\w\s.,?!]/gi, '');
        const utterance = new SpeechSynthesisUtterance(cleanText);
        utterance.pitch = 1.1;
        utterance.rate = 1.0;
        window.speechSynthesis.speak(utterance);
    }

    // Wrap existing addMessage to include speech
    const originalAddMessage = addMessage;
    addMessage = (text, isUser = false) => {
        originalAddMessage(text, isUser);
        if (!isUser) speakReply(text);
    };
});
</script>

<style>
    .recording {
        border-color: #e11d48 !important;
        background: rgba(225, 29, 72, 0.1) !important;
        box-shadow: 0 0 15px rgba(225, 29, 72, 0.3);
    }
</style>
