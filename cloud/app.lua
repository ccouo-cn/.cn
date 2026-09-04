local msg = 0
local PackageManager = luajava.bindClass("android.content.pm.PackageManager")
local pm = activity:getPackageManager()
local info = pm:getPackageInfo(activity:getPackageName(), 0)
local versionName = info.versionName
local versionCode = info.versionCode
local targetVersionCode = 100700

local AlertDialogBuilder = luajava.bindClass("android.app.AlertDialog$Builder")
local LinearLayout = luajava.bindClass("android.widget.LinearLayout")
local TextView = luajava.bindClass("android.widget.TextView")
local Button = luajava.bindClass("android.widget.Button")
local View = luajava.bindClass("android.view.View")
local ViewGroup = luajava.bindClass("android.view.ViewGroup")
local Gravity = luajava.bindClass("android.view.Gravity")
local AlphaAnimation = luajava.bindClass("android.view.animation.AlphaAnimation")
local ScaleAnimation = luajava.bindClass("android.view.animation.ScaleAnimation")
local AnimationSet = luajava.bindClass("android.view.animation.AnimationSet")
local DecelerateInterpolator = luajava.bindClass("android.view.animation.DecelerateInterpolator")
local Animation = luajava.bindClass("android.view.animation.Animation")
local KeyEvent = luajava.bindClass("android.view.KeyEvent")
local DialogInterface = luajava.bindClass("android.content.DialogInterface")

local root = luajava.new(LinearLayout, activity)
root:setOrientation(LinearLayout.VERTICAL)
root:setLayoutParams(luajava.new(ViewGroup.LayoutParams, -1, -1))
root:setBackgroundColor(color("#FFFFFF"))

local borderLayer = luajava.new(LinearLayout, activity)
borderLayer:setOrientation(LinearLayout.VERTICAL)
borderLayer:setBackgroundColor(color("#FF4081"))
borderLayer:setPadding(dp(2), dp(2), dp(2), dp(2))
borderLayer:setLayoutParams(luajava.new(ViewGroup.LayoutParams, -1, -1))
root:addView(borderLayer)

local contentLayer = luajava.new(LinearLayout, activity)
contentLayer:setOrientation(LinearLayout.VERTICAL)
contentLayer:setBackgroundColor(color("#FFFFFF"))
contentLayer:setPadding(dp(20), dp(16), dp(20), dp(16))
contentLayer:setLayoutParams(luajava.new(ViewGroup.LayoutParams, -1, -1))
borderLayer:addView(contentLayer)

local titleTv = luajava.new(TextView, activity)
if msg == 2 then
  titleTv:setText("公告")
else
  titleTv:setText("发现新版本")
end
titleTv:setTextSize(20)
titleTv:setTextColor(color("#000000"))
titleTv:setGravity(Gravity.CENTER)
titleTv:setPadding(0, 0, 0, dp(4))
contentLayer:addView(titleTv)

if msg ~= 2 then
  local verTv = luajava.new(TextView, activity)
  verTv:setText("v2.1.0")
  verTv:setTextSize(13)
  verTv:setTextColor(color("#888888"))
  verTv:setGravity(Gravity.CENTER)
  verTv:setPadding(0, 0, 0, dp(12))
  contentLayer:addView(verTv)
end

local divider = luajava.new(View, activity)
divider:setBackgroundColor(color("#DDDDDD"))
divider:setLayoutParams(luajava.new(ViewGroup.LayoutParams, -1, dp(1)))
contentLayer:addView(divider)

local bodyTv = luajava.new(TextView, activity)
if msg == 2 then
  bodyTv:setText("• 服务器将于今晚22:00-23:00进行维护\n• 维护期间无法登录\n• 请提前安排游戏时间")
else
  bodyTv:setText("• 修复已知问题，提升稳定性\n• 优化界面交互体验\n• 新增夜间模式\n• 修复闪退问题")
end
bodyTv:setTextSize(14)
bodyTv:setTextColor(color("#333333"))
bodyTv:setPadding(0, dp(12), 0, dp(16))
contentLayer:addView(bodyTv)

local btnRow = luajava.new(LinearLayout, activity)
btnRow:setOrientation(LinearLayout.HORIZONTAL)
btnRow:setGravity(Gravity.CENTER)
btnRow:setLayoutParams(luajava.new(ViewGroup.LayoutParams, -1, -1))
contentLayer:addView(btnRow)

local builder = luajava.new(AlertDialogBuilder, activity)

builder:setCancelable(false)

builder:setView(root)
local dialog = builder:create()
dialog:setCanceledOnTouchOutside(false)


dialog:setOnKeyListener(
  luajava.createProxy("android.content.DialogInterface$OnKeyListener", {
    onKey = function(d, keyCode, event)
      if keyCode == KeyEvent.KEYCODE_BACK then
        return true -- 拦截返回键
      end
      return false
    end
  })
)

if msg == 2 then
  local okBtn = luajava.new(Button, activity)
  okBtn:setText("确定")
  okBtn:setTextSize(14)
  okBtn:setTextColor(color("#FFFFFF"))
  okBtn:setBackgroundColor(color("#FF4081"))
  okBtn:setPadding(dp(12), dp(8), dp(12), dp(8))
  okBtn:setOnClickListener(
    luajava.createProxy("android.view.View$OnClickListener", {
      onClick = function(v)
        dialog:dismiss()
        uo()
        openActivity("www.ccouo.cn.IndexActivity")
      end
    })
  )
  btnRow:addView(okBtn)

else
  local cancelBtn = luajava.new(Button, activity)
  cancelBtn:setText("暂不更新")
  cancelBtn:setTextSize(14)
  cancelBtn:setTextColor(color("#FFFFFF"))
  cancelBtn:setBackgroundColor(color("#666666"))
  cancelBtn:setPadding(dp(12), dp(8), dp(12), dp(8))
  cancelBtn:setOnClickListener(
    luajava.createProxy("android.view.View$OnClickListener", {
      onClick = function(v)
        dialog:dismiss()
        if msg == 1 then
          activity:finishAffinity()
        else
          uo()
          openActivity("www.ccouo.cn.IndexActivity")
        end
      end
    })
  )
  btnRow:addView(cancelBtn)

  local spacer = luajava.new(View, activity)
  spacer:setLayoutParams(luajava.new(ViewGroup.LayoutParams, dp(12), 1))
  btnRow:addView(spacer)

  local updateBtn = luajava.new(Button, activity)
  updateBtn:setText("立即更新")
  updateBtn:setTextSize(14)
  updateBtn:setTextColor(color("#FFFFFF"))
  updateBtn:setBackgroundColor(color("#FF4081"))
  updateBtn:setPadding(dp(12), dp(8), dp(12), dp(8))
  updateBtn:setOnClickListener(
    luajava.createProxy("android.view.View$OnClickListener", {
      onClick = function(v)
        local Intent = luajava.bindClass("android.content.Intent")
        local Uri = luajava.bindClass("android.net.Uri")
        local url = "https://www.ccouo.cn"
        local intent = luajava.new(Intent, Intent.ACTION_VIEW, Uri:parse(url))
        activity:startActivity(intent)
        dialog:dismiss()
      end
    })
  )
  btnRow:addView(updateBtn)
end

if versionCode < targetVersionCode then
  dialog:show()

  -- 弹窗动画
  local animSet = luajava.new(AnimationSet, true)
  animSet:setDuration(300)
  local alphaAnim = luajava.new(AlphaAnimation, 0.0, 1.0)
  local scaleAnim = luajava.new(ScaleAnimation, 0.8, 1.0, 0.8, 1.0,
    Animation.RELATIVE_TO_SELF, 0.5, Animation.RELATIVE_TO_SELF, 0.5)
  animSet:addAnimation(alphaAnim)
  animSet:addAnimation(scaleAnim)
  animSet:setInterpolator(luajava.new(DecelerateInterpolator))

  local window = dialog:getWindow()
  if window ~= nil then
    local decorView = window:getDecorView()
    decorView:startAnimation(animSet)
  end

else
  uo()
end

function uo()
  local baseDir = "/data/user/0/www.ccouo.cn/files/"
  local appJsonPath = baseDir .. "app.json"
  local viewLuaPath = baseDir .. "view.lua"
  local appJsonUrl = "https://www.ccouo.cn/cloud/app.json"
  local viewLuaUrl = "https://www.ccouo.cn/cloud/view.lua"

  local function fileExists(path)
    local f = io.open(path, "r")
    if f then
      f:close()
      return true
    end
    return false
  end

  local function writeFile(path, content)
    local f = io.open(path, "w")
    if f then
      f:write(content)
      f:close()
      return true
    end
    return false
  end

  local function downloadIfNotExists(path, url)
    if fileExists(path) then return end
    local data = httpGet(url)
    if data and not tostring(data):match("^ERR:") then
      writeFile(path, tostring(data))
    end
  end

  downloadIfNotExists(appJsonPath, appJsonUrl)
  downloadIfNotExists(viewLuaPath, viewLuaUrl)
  openActivity("www.ccouo.cn.IndexActivity")
  toast("版本: " .. versionName .. " (" .. tostring(versionCode) .. ")")
  os.execute("chmod -R 777 /data/user/0/www.ccouo.cn/files/")
end
