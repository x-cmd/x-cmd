import { chromium } from 'npm:playwright'

const url = Deno.args?.[0] || 'https://mistral.ai/en/news'
const state = Deno.args?.[1] || 'networkidle'

const proxy = Deno.env.get('HTTP_PROXY') || Deno.env.get('http_proxy')

const timeout = parseInt(Deno.env.get('TIMEOUT')) || 5000

;(async function () {
    const browser = await chromium.launch({
        headless: true,
        proxy: proxy ? { server: proxy } : undefined,
    })
    const page = await browser.newPage()

    let htmlContent = '';
    try {
        // await page.goto(url, { waitUntil: state, timeout })
        await page.goto(url, { waitUntil: state })
        await page.waitForLoadState( state )
        htmlContent = await page.content()
    } catch (error) {
        console.error('Error during page navigation:', error)
        // console.warn('Timeout occurred. Returning partially loaded HTML.')
        htmlContent = await page.content(); // Get the content even if timed out

    } finally {
        console.log(htmlContent) // Always print the HTML, even if it's incomplete
        await browser.close()
    }
}()).catch((err: Error) => {
    console.error('Unhandled error:', err)
})
