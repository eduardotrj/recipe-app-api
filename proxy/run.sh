#!/bin/sh

set -e          #→ (𝖨𝖿 𝖿𝖺𝗂𝗅𝗌 𝖺𝗇𝗒 𝖼𝗈𝗆𝗆𝖺𝗇𝖽𝗌 𝖺𝖿𝗍𝖾𝗋, 𝗐𝗁𝗈𝗅𝖾 𝗌𝖼𝗋𝗂𝗉𝗍 𝖿𝖺𝗂𝗅𝗌)

envsubst < /etc/nginx/default.conf.tpl > /etc/nginx/conf.d/default.conf
                #→ (𝖯𝗎𝗍 𝗍𝗁𝖾 𝖿𝗂𝗅𝖾 𝖺𝗇𝖽 𝗌𝗎𝖻𝗌, 𝗍𝗁𝖾 𝖽𝖺𝗍𝖺 𝗐𝗂𝗍𝗁 𝖾𝗇𝗏𝗂𝗋𝗈𝗆𝖾𝗇𝗍 𝗏𝖺𝗋𝗌)
nginx -g 'daemon off;'
                #→ (𝖳𝗈 𝗋𝗎𝗇 𝗂𝗇 𝗍𝗁𝖾 𝖿𝗈𝗋𝖾𝗀𝗋𝗈𝗎𝗇𝖽, 𝗈𝗏𝖾𝗋 𝖺𝗅𝗅 𝗌𝗍𝗎𝖿𝖿)