## Usage

```
  /**
   * 初始化
   * @param  {option} 初始化参数
   *    accessKey:API 令牌,
   *    phone:用户唯一登录账号，手机号
   * @param  {Function} successCallback 成功回调
   * @return {void}  
   */
  init(option, successCallback, errorCallback) {
    option = option || {}
    this.callNative('init', [option], successCallback， errorCallback)
  },

  /**
   * 融云推送消息透传或系统消息回调
   * @param  {Function} successCallback 成功回调
   * @return {void}  
   */
  onMessage(successCallback)

  /**
   * 系统消息,公司通知点击事件
   * @param  {Function} successCallback 
   * 系统消息：'system_notice'，公司通知：'company_notice'
   * @return {void}  
   */
  onClick(successCallback)

  /**
   * 监听消息数，不包括系统消息，公司通知
   * @param  {Function} successCallback 成功回调
   * @return 未读消息数
   */
  onBadge(successCallback)


  /**
   * 监听通知到达，（更新系统消息,公司通知未读数）
   * @param  {Function} successCallback 成功回调
   * @return {void}
   */
  onNotify(successCallback)

  /**
   * 设置公司通知未读数
   * @param  count 公司通知未读数
   * @param  {Function} successCallback 成功回调
   * @param  {Function} errorCallback 失败回调
   * @return 未读消息总数
   */
  setCompanyBadge(count, successCallback, errorCallback)

  /**
    * 设置系统通知未读数
   * @param  count 系统消息未读数
   * @param  {Function} successCallback 成功回调
   * @param  {Function} errorCallback 失败回调
    * @return 未读消息总数
    */
  setSystemBadge: function(count, successCallback, errorCallback) 

  /**
   * 控制显示
   * @param  option {fixedPixelsTop:头距离，默认为0,fixedPixelsBottom:底距离默认为0}
   * @param  {Function} successCallback 成功回调
   * @return {void}  
   */
  show(option, successCallback)

  /**
   * 控制隐藏
   * @param  {Function} successCallback 成功回调
   * @return {void}  
   */
  hide: function(successCallback)


  /**
   * 融云登出
   * @param  {Function} successCallback 成功回调
   * @return {void}  
   */
  logout(successCallback) 
  ```