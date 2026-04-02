// Supabase Edge Function: 百度AI脸型分析代理
// 部署命令: supabase functions deploy baidu-face-api

Deno.serve(async (req) => {
  // CORS headers
  const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  }

  // Handle OPTIONS request
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const { image_base64 } = await req.json()

    // 百度 AI 配置
    const BAIDU_API_KEY = 'FTlyvTHFFBYRWWAtCsmvjcPG'
    const BAIDU_SECRET_KEY = 'pVJ5qSvaEvdqcsSHv4DNTJH3t5iIdzeo'

    // 获取 Access Token
    const tokenRes = await fetch(
      `https://aip.baidubce.com/oauth/2.0/token?grant_type=client_credentials&client_id=${BAIDU_API_KEY}&client_secret=${BAIDU_SECRET_KEY}`
    )
    const tokenData = await tokenRes.json()
    const accessToken = tokenData.access_token

    // 调用脸型分析 API
    const faceRes = await fetch(
      `https://aip.baidubce.com/rest/2.0/face/v3/detect?access_token=${accessToken}`,
      {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          image: image_base64,
          image_type: 'BASE64',
          face_field: 'age,beauty,expression,face_shape,gender,glasses',
        }),
      }
    )

    const faceData = await faceRes.json()

    return new Response(JSON.stringify(faceData), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    })
  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    })
  }
})
