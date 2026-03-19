import { DOMParser, Node } from "https://deno.land/x/deno_dom/deno-dom-wasm.ts";

async function removeUnused(html: string): Promise<string | null> {
  try {
    const dom = new DOMParser().parseFromString(html, "text/html");

    ["script", "svg", "meta", "style", "link", "comment"].forEach(
      (t) => dom.querySelectorAll(t).forEach((e) => e.remove()),
    );

    dom.querySelectorAll("img").forEach((img) => {
      const src = img.getAttribute("src");
      if (src && src.startsWith("data:image/")) {
        img.remove();
      }
    });

    function removeCommentNodes(node: Node): void {
      let child = node.firstChild;
      while (child) {
        const nextSibling = child.nextSibling; // Store next sibling before removal
        if (child.nodeType === Node.COMMENT_NODE) {
          node.removeChild(child);
        } else {
          removeCommentNodes(child);
        }
        child = nextSibling; // Use stored next sibling
      }
    }
    removeCommentNodes(dom); //Start at the root of the DOM

    // remove more attributes

    // dom.querySelectorAll("a").forEach(a => {
    //   const href = a.getAttribute("href");
    //   // if (href && href.startsWith("http")) {
    //     a.setAttribute("href", "http://link");
    //   // }
    // });

    return dom.documentElement.outerHTML;
  } catch (error) {
    console.error("Error processing HTML:", error);
    return null;
  }
}

const decoder = new TextDecoder("utf-8");
let html = "";
const buf = new Uint8Array(1024); // Adjust buffer size as needed
while (true) {
  const n = await Deno.stdin.read(buf);
  if (n === null) break;
  html += decoder.decode(buf.subarray(0, n));
}

const cleanedHtml = await removeUnused(html);
if (cleanedHtml) {
  console.log(cleanedHtml);
}
