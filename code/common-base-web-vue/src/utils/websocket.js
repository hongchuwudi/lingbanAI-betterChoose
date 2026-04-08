class WebSocketService {
  constructor(url, options = {}) {
    this.url = url
    this.ws = null
    this.callbacks = new Map()
    this.reconnectAttempts = 0
    this.maxReconnectAttempts = options.maxReconnectAttempts || 5
    this.reconnectInterval = options.reconnectInterval || 3000
    this.isConnecting = false
  }
  
  connect() {
    if (this.isConnecting) return
    this.isConnecting = true
    
    try {
      this.ws = new WebSocket(this.url)
      
      this.ws.onopen = () => {
        console.log('WebSocket connected')
        this.isConnecting = false
        this.reconnectAttempts = 0
      }
      
      this.ws.onmessage = (event) => {
        try {
          const data = JSON.parse(event.data)
          const callback = this.callbacks.get(data.type)
          if (callback) {
            callback(data.data)
          }
          // 也可以触发通用消息事件
          const messageCallback = this.callbacks.get('*')
          if (messageCallback) {
            messageCallback(data)
          }
        } catch (error) {
          console.error('Parse message error:', error)
        }
      }
      
      this.ws.onclose = () => {
        console.log('WebSocket disconnected')
        this.isConnecting = false
        this.reconnect()
      }
      
      this.ws.onerror = (error) => {
        console.error('WebSocket error:', error)
        this.isConnecting = false
      }
    } catch (error) {
      console.error('WebSocket connection error:', error)
      this.isConnecting = false
    }
  }
  
  reconnect() {
    if (this.reconnectAttempts >= this.maxReconnectAttempts) {
      console.error('Max reconnect attempts reached')
      return
    }
    
    this.reconnectAttempts++
    console.log(`Reconnecting... Attempt ${this.reconnectAttempts}`)
    
    setTimeout(() => {
      this.connect()
    }, this.reconnectInterval)
  }
  
  send(type, data) {
    if (this.ws && this.ws.readyState === WebSocket.OPEN) {
      this.ws.send(JSON.stringify({ type, data }))
    } else {
      console.warn('WebSocket is not connected')
    }
  }
  
  on(type, callback) {
    this.callbacks.set(type, callback)
  }
  
  off(type) {
    this.callbacks.delete(type)
  }
  
  close() {
    if (this.ws) {
      this.ws.close()
      this.ws = null
    }
    this.callbacks.clear()
  }
  
  get isConnected() {
    return this.ws && this.ws.readyState === WebSocket.OPEN
  }
}

export default WebSocketService