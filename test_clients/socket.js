class Socket {
    constructor(){
        this.clients = {};
        this.socket = new WebSocket('ws://localhost:8000');
        this.id = parseInt(document.getElementById('in_id').value);
        this.images ={
            image1:document.getElementById('in_image1').value,
            image2:document.getElementById('in_image2').value,
        } 
        this.label = document.getElementById('in_info');
        this.contacts = document.getElementById('div_contacts');
        this.messages = document.getElementById('div_messages');
        this.msg_container = {};
        this.current_room = null;
        this.connect();
        
    }

    connect(){
        this.socket.addEventListener('open', (event) =>{
            this.label.value = 'Sunucu OK ..';
            this.socket.send('{"id":"'+this.id+'","event":"register"}');
            //call all users
            this.socket.send('{"id":"'+this.id+'","event":"1"}');
        });
        this.events();
    }


    events(){
        this.socket.addEventListener('message', (event) => {
            //decode message
            let data = JSON.parse(event.data);
            console.log(data);
            switch(parseInt(data.event)){
                case 1:
                    //console.log(data);
                    //get client event transaction
                    this.eventClient(data)
                    break;
                case 2:
                    //get all list transactions
                    this.contacts.innerHTML = '';
                    for(let i=0;i<data.data.length;i++){
                        if(this.clients[data.data.id] === undefined){
                            this.clients[data.data[i].id] = data.data[i];
                            this.contacts.innerHTML+=this.addClient(data.data[i]);
                        } 
                    }
                    break;
                case 3:
                    //message come
                    this.setMessage({
                        owner:parseInt(data.data.owner),
                        target:this.id,
                        type:1,
                        msg: data.data.msg
                    });
                    break;    
            }
            console.log('Mesaj alındı: ', event.data);
        });

        this.socket.addEventListener('close', (event) => {
            setTimeout(() => {
                this.connect();
            }, 100);
        });

        //when person selected
        this.contacts.addEventListener('click',e=>{
            if(e.target.classList.contains('active1')){
                
                this.messages.innerHTML = '';
                let target = parseInt(e.target.id.split('_')[1]);
                document.getElementById('icon_'+target).hidden = true;
                document.getElementById('icon_'+target).classList.remove('blink_me');
                //person selected
                this.current_room = this.id+'-'+target;
                //set header
                document.getElementById('spn_name').innerHTML = target;
                document.getElementById('in_msg').value = '';
                //set messages if exists
                if(this.msg_container[this.id+'-'+target] !== undefined){
                    for(let i = 0;i<this.msg_container[this.id+'-'+target].length;i++){
                        let type = this.msg_container[this.id+'-'+target][i].owner === this.id ? 0 : 1; 
                        this.setMessageHtml(this.msg_container[this.id+'-'+target][i]);
                    }
                }
            }
        });

        //listen enter
        document.getElementById('in_msg').addEventListener('keypress', function (e) {
            if (e.key === 'Enter') {
              document.getElementById('btn_send').dispatchEvent(new Event('click'));
            }
        });
        //when message sending 
        document.getElementById('btn_send').addEventListener('click',()=>{
            if(this.current_room !== null){
                let elm = document.getElementById('in_msg');
                if(elm.value.trim().length>0){
                    let target = parseInt(this.current_room.split('-')[1]);
                    //send message to socket
                    this.socket.send('{"id":"'+this.id+'","event":"3","target":"'+target+'","msg":"'+elm.value.trim()+'"}');
                    this.setMessage({
                        owner:this.id,
                        target :target,
                        type:0,
                        msg:elm.value.trim()
                    });
                }else{
                    this.toast('Mesaj Giriniz !!');  
                }
                elm.value = '';
            }else{  
                this.toast('Kişi Seçiniz !!');
            }
        });
    }


    eventClient(data){
        //get client connected transaction
        switch(data.type){
            case '1':
                //client registered
                if(this.clients[data.data.id] === undefined && parseInt(data.data.id) !== this.id){
                    console.log(data);
                    this.clients[data.data.id] = data.data;
                    this.contacts.innerHTML+=this.addClient(data.data);
                    this.toast(data.data['id']+' is connected..');
                }
                break;
            case '2':
                //client dropped
                this.toast(this.clients[data.data.id].id +' is  dropped..');
                delete this.clients[data.data.id];
                document.getElementById('per_'+data.data.id).outerHTML = '';
                
                break;
        }
    }


    addClient(data){
        if(data.id != this.id){
            return `<li class="active1" id="per_`+data.id+`">
                        <div class="d-flex bd-highlight" style="pointer-events:none;">
                            <div class="img_cont">
                                <img src="`+this.images.image2+`" class="rounded-circle user_img">
                                <span class="online_icon"></span>
                            </div>
                            <div class="user_info">
                                <div>
                                <span>`+data.id+`</span>
                                <p>`+data.id+` is online</p>
                                </div>
                                <i id="icon_`+data.id+`" class="fa fa-circle" hidden style="color:red"></i>
                                
                            </div>
                        </div>
                    </li>`;
        }
    }

    toast(msg){
        let tel = document.createElement('div');
        tel.id = 'snackbar';
        tel.innerHTML = msg;
        tel.classList.add('show');
        document.body.appendChild(tel);
        setTimeout(()=>{tel.outerHTML = ''; }, 3000);
    }

    setMessage(obj){
        let key = this.id + '-'+ (() => {return obj.type === 0 ? obj.target : obj.owner})();
        if(this.msg_container[key] === undefined)this.msg_container[key] = [];
        obj.date = new Date().toLocaleString();
        this.msg_container[key].push(obj);
        if(this.current_room !== null && this.current_room === key){
            this.setMessageHtml(obj);
        }else{
            //blink
            document.getElementById('icon_'+key.split('-')[1]).hidden = false;
            document.getElementById('icon_'+key.split('-')[1]).classList.add('blink_me');
        }
    }

    setMessageHtml(obj){
        console.log(obj);
        let coming = `<div class="d-flex justify-content-start mb-4">
                        <div class="img_cont_msg">
                            <img src="`+this.images.image1+`" class="rounded-circle user_img_msg">
                        </div>
                        <div class="msg_cotainer">
                            `+obj.msg+`
                            <span class="msg_time">`+obj.date+`</span>
                        </div>
                    </div>`;
        let going = `<div class="d-flex justify-content-end mb-4">
                        <div class="msg_cotainer_send">
                            `+obj.msg+`
                            <span class="msg_time_send">`+obj.date+`</span>
                        </div>
                        <div class="img_cont_msg">
                            <img src="`+this.images.image2+`" class="rounded-circle user_img_msg">
                        </div>
                    </div>`;

        //add message to messagebox
        this.messages.innerHTML+=obj.type === 1 ? coming : going;            
    }
}