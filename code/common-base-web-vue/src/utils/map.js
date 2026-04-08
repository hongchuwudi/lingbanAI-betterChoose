// 百度地图初始化
export const initBMap = (ak) => {
  return new Promise((resolve, reject) => {
    if (window.BMapGL) {
      resolve(window.BMapGL)
      return
    }
    
    const script = document.createElement('script')
    script.src = `https://api.map.baidu.com/api?v=1.0&type=webgl&ak=${ak}&callback=initBMapCallback`
    script.onerror = reject
    document.head.appendChild(script)
    
    window.initBMapCallback = () => {
      resolve(window.BMapGL)
    }
  })
}

// 创建地图实例
export const createMap = (container, options = {}) => {
  if (!window.BMapGL) {
    throw new Error('BMapGL not loaded')
  }
  return new window.BMapGL.Map(container, options)
}

// 创建点标记
export const createMarker = (point, options = {}) => {
  if (!window.BMapGL) return null
  return new window.BMapGL.Marker(point, options)
}

// 创建信息窗口
export const createInfoWindow = (content, options = {}) => {
  if (!window.BMapGL) return null
  return new window.BMapGL.InfoWindow(content, options)
}