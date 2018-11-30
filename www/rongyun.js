var exec = require('cordova/exec');

var Rongyun = {
    errorCallback: function(msg) {
        console.error('Rongyun Callback Error: ' + msg)
    },

    callNative: function(name, args, successCallback, errorCallback) {
        if (errorCallback) {
            cordova.exec(successCallback, errorCallback, 'Rongyun', name, args)
        } else {
            cordova.exec(successCallback, this.errorCallback, 'Rongyun', name, args)
        }
    },

    /**
     * 初始化
     * @param  {option} 初始化参数
     *    accessKey,
     *    phone
     * @param  {Function} successCallback 成功回调
     * @return {void}  
     */
    init: function(option, successCallback, errorCallback) {
        option = option || {}
        this.callNative('init', [option], successCallback, errorCallback)
    },

    /**
     * 融云推送消息透传或系统消息回调
     * @param  {Function} successCallback 成功回调
     * @return {void}  
     */
    onMessage: function(successCallback, errorCallback) {
        this.callNative('onMessage', [], successCallback, errorCallback)
    },

    /**
     * 系统消息,公司通知点击事件
     * @param  {Function} successCallback 系统消息：'rong_system_notice'，公司通知：'rong_company_notice'
     * @return {void}  
     */
    onClick: function(successCallback) {
        this.callNative('onClick', [], successCallback)
    },

    /**
     * 监听通知变化
     * @param  {Function} successCallback 成功回调
     * @return {void}
     */
    onBadge: function(successCallback) {
        this.callNative('onBadge', [], successCallback)
    },

    /**
     * 监听通知变化
     * @param  {Function} successCallback 成功回调
     * @return {void}
     */
    onNotify: function(successCallback) {
        this.callNative('onNotify', [], successCallback)
    },

    /**
     * 设置公司通知未读数
     * @param  {Function} successCallback 成功回调
     * @return {void}
     */
    setCompanyBadge: function(count, successCallback, errorCallback) {
        this.callNative('setCompanyBadge', [count], successCallback)
    },

    /**
     * 设置系统通知未读数
     * @param  {Function} successCallback 成功回调
     * @return {void}
     */
    setSystemBadge: function(count, successCallback, errorCallback) {
        this.callNative('setSystemBadge', [count], successCallback)
    },
    /**
     * 控制显示
     * @param  option {fixedPixelsTop:头距离，默认为0,fixedPixelsBottom:底距离默认为0}
     * @param  {Function} successCallback 成功回调
     * @return {void}  
     */
    show: function(option, successCallback, errorCallback) {
        option = option || {}
        this.callNative('show', [option], successCallback, errorCallback)
    },

    /**
     * 控制隐藏
     * @param  {Function} successCallback 成功回调
     * @return {void}  
     */
    hide: function(successCallback, errorCallback) {
        this.callNative('hide', [], successCallback, errorCallback)
    },

    /**
     * 融云登出
     * @param  {Function} successCallback 成功回调
     * @return {void}  
     */
    logout: function(successCallback, errorCallback) {
        this.callNative('logout', [], successCallback, errorCallback)
    }
}
module.exports = Rongyun;