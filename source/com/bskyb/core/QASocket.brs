'' QASocket.brs
'' Copyright (c) 2013 BSkyB All Right Reserved
''
'' HIGHLY CONFIDENTIAL INFORMATION OF BSKYB.
'' COPYRIGHT BSKYB. ALL COPYING, DISSEMINATION 
'' OR DISTRIBUTION STRICTLY PROHIBITED.

function QASocket()
    if(m.qaSocketInstance = invalid)
    
        this = {}
        
        ' STATIC PROPERTIES
        this.TOSTRING = "<QASocket>"
        this.PORT = 7777
        
        ' PROPERTIES
        this.msgPort = invalid
        this.listenSocket = createObject("roStreamSocket")
        this.clientConnection = invalid
        this.readBuffer = createObject("roByteArray")
        this.readBuffer[512] = 0
        this.responseBuffer = createObject("roByteArray")
    
        ' METHODS
        this.init = function(msgPort as Object)
            addr = createObject("roSocketAddress")
            addr.setPort(m.PORT)
            
            m.msgPort = msgPort
            m.listenSocket.setMessagePort(msgPort)
            m.listenSocket.setAddress(addr)
            m.listenSocket.notifyReadable(true)
            m.listenSocket.listen(4)
            if (not m.listenSocket.eOK()) stop
            
        end function
        
        this.processMessage = function(msg as Object)
            if m.listenSocket.isReadable()
                ' New Connection.  If there was an existing connection, we just close it.
                if m.clientConnection <> Invalid
                    m.clientConnection.close()
                end if

            m.clientConnection = m.listenSocket.accept()
            m.clientConnection.notifyReadable(true)
            m.clientConnection.setMessagePort(m.msgPort)
            
            end if
        
            if m.clientConnection <> Invalid and m.clientConnection.isReadable()
                ' Activity on the client connection
                received = m.clientConnection.receive(m.readBuffer, 0, 512)
                func = ""
                if received > 0
                    for i=0 to received-1
                        func = func + Chr(m.readBuffer[i])
                    end for
                end if
                
                print "evaluate : " ; func
                
                output = eval(func)
                print output
            else
                ' client closed
                m.clientConnection.close()
                m.clientConnection = Invalid
            end if
                
            
        end function
        
        m.qaSocketInstance = this
        
    end if
    
    return m.qaSocketInstance
end function