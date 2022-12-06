import Foundation
import TelegramBotSDK

let token = readToken(from: "TOKEN")

let bot = TelegramBot(token: token)

let router = Router(bot: bot)

router["help"] = { context in
    guard let from = context.message?.from else { return false }

    let helpText = "Usage: /greet"
    context.respondPrivatelyAsync(helpText,
            groupText: "\(from.firstName), please find usage instructions in a personal message.")
    return true
}

router["greet"] = { context in
    guard let from = context.message?.from else { return false }
    context.respondAsync("Hello, \(from.firstName)!")
    return true
}

router[.newChatMembers] = { context in
    guard let users = context.message?.newChatMembers,
          let chatId = context.chatId,
          let messageId = context.message?.messageId
    else { return false }
    
    for user in users {
        guard user.id != bot.user.id else { return false }
        context.respondAsync("W3lc0m3, \(user.firstName)!")
    }
    
    bot.deleteMessageAsync(chatId: ChatId.chat(chatId), messageId: messageId)
    
    return true
}

print("Ready to accept commands")
while let update = bot.nextUpdateSync() {
    try router.process(update: update)
}

fatalError("Server stopped due to error: \(bot.lastError.unwrapOptional)")
