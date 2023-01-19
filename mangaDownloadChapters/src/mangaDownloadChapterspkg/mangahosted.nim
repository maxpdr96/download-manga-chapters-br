import algorithm, httpclient, xmltree, nimquery, os, re
from htmlparser import parseHtml

proc getHtmlBody(url: string): XmlNode = 
    var client = newHttpClient()
    var html = client.getContent(url)
    return parseHtml(html)

proc getTitle(html: XmlNode): string =
    var title = html.querySelector("h1.title").innerText.replace(re("[^a-zA-Z0-9 ]"))
    return title

proc createDirectory(destiny: string): bool =
    if not dirExists(destiny):
        createDir(destiny)
        return true

proc downloadChapter(linkChapter: string, folderChapter: string) =
    var client = newHttpClient()
    echo folderChapter
    var htmlChapter = client.getContent(linkChapter)
    let xmlChapter = parseHtml(htmlChapter)
    var imagesChapter = xmlChapter.querySelectorAll("#slider img")
    var count = 1
    for imageChapter in imagesChapter:
        var imageUrl = imageChapter.attr("src")
        var response = client.get(imageUrl)
        echo response.status & " To " & imageUrl
        if response.status == "200 OK":
            var file = open(folderChapter & "/image-" & $count & ".jpg", fmWrite)
            file.write(response.body)
            file.close()

        count += 1

proc downloadChapters(url: string, html: XmlNode, title: string) = 
    var nodeChapters = html.querySelectorAll(".chapters .btn-caps")
    for chapters in reversed(nodeChapters):
        var linkChapters = chapters.innerText
        var linkChapter = url & "/" & linkChapters
        var folderChapter = title & "/" & linkChapters
        if createDirectory(folderChapter):
            echo "Link chapter is: " & linkChapter
            downloadChapter(linkChapter, folderChapter)
    echo "Fim"    
    

proc execManga*()=
    echo "Enter mangahosted link: "
    var url = readLine(stdin)
    var htmlBody = getHtmlBody(url)
    var title = getTitle(htmlBody)
    if createDirectory(title):
        echo "Created a directory for the manga"
    else:
        echo "Did not create directory"
    
    downloadChapters(url, htmlBody, title)