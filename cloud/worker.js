// 允许的域名
const ALLOWED_DOMAINS = ['t.me', 'telegram.me', 'telesco.pe'];
const IMG_EXT = ['.jpg', '.jpeg', '.png', '.gif', '.webp', '.bmp', '.svg'];

export default {
  async fetch(request) {
    const url = new URL(request.url);

    // CORS / OPTIONS
    if (request.method === 'OPTIONS') {
      return new Response(null, {
        headers: {
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'GET, OPTIONS',
        },
      });
    }

    // 1. 获取 j 参数
    const j = url.searchParams.get('j');
    if (!j) {
      return new Response('Missing "j" parameter', { status: 400 });
    }

    // 2. 补全 https 并校验域名
    let targetUrl = j;
    if (!/^https?:\/\//i.test(targetUrl)) {
      targetUrl = 'https://' + targetUrl;
    }

    let parsedUrl;
    try {
      parsedUrl = new URL(targetUrl);
    } catch {
      return new Response('Invalid URL', { status: 400 });
    }

    if (!ALLOWED_DOMAINS.includes(parsedUrl.hostname.toLowerCase())) {
      return new Response('Forbidden domain', { status: 403 });
    }

    try {
      // 3. 抓取 Telegram 页面
      const tgResp = await fetch(targetUrl, {
        headers: {
          'User-Agent': 'Mozilla/5.0',
        },
      });

      if (!tgResp.ok) {
        return new Response('Failed to fetch Telegram page', { status: 502 });
      }

      const html = await tgResp.text();

      // 4. 解析 cdn4.telesco.pe
      const cdnUrls = [...new Set(
        html.match(/https?:\/\/cdn4\.telesco\.pe\/[^"'\\s<>]+/gi) || []
      )];

      if (cdnUrls.length === 0) {
        return new Response('No telesco.pe image found', { status: 404 });
      }

      // 5. 选图
      let imageUrl = cdnUrls[0];
      const lowerHtml = html.toLowerCase();
      for (const u of cdnUrls) {
        const lowerUrl = u.toLowerCase();
        if (IMG_EXT.some(ext => lowerUrl.includes(ext))) {
          imageUrl = u;
          break;
        }
      }

      // 6. 直连 CDN 并返回（关键步骤）
      const imageResp = await fetch(imageUrl, {
        headers: {
          'User-Agent': 'Mozilla/5.0',
          'Referer': 'https://t.me/',
        },
      });

      if (!imageResp.ok) {
        return new Response('Failed to fetch image', { status: 502 });
      }

      // 7. 流式返回图片
      const headers = new Headers(imageResp.headers);
      headers.set('Cache-Control', 'public, max-age=86400');
      headers.set('Access-Control-Allow-Origin', '*');

      return new Response(imageResp.body, {
        status: 200,
        headers,
      });

    } catch (err) {
      return new Response('Internal Error: ' + err.message, { status: 500 });
    }
  },
};

