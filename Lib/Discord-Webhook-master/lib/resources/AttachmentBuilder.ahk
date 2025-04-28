/************************************************************************
 * @description Part of ninjus Discord.ahk library
 * @file AttachmentBuilder.ahk
 * @author ninju | .ninju.
 * @date 2024/07/12
 * @version 0.0.1
 ***********************************************************************/

class AttachmentBuilder {
    /**
     * new AttachmentBuilder()
     * @param param File path or bitmap identifier
     */
    __New(param) {
        this.isBitmap := 1
        this.fileName := "image.png"
        this.file := param

        if FileExist(param) {
            if InStr(FileExist(param), "D")
                throw Error("AttachmentBuilder: Expected a file but got a directory.", , param)
            try {
                loop files param
                    this.file := A_LoopFileFullPath, this.fileName := A_LoopFileName, this.isBitmap := 0
            } catch {
                throw Error("AttachmentBuilder: Failed to access file.", , param)
            }
        }
        else {
            try {
                Integer(param)
            } catch {
                throw Error("AttachmentBuilder: Invalid parameter (not a file, not a bitmap ID).", , param)
            }
        }

        ; Build attachment info
        this.attachmentName := "attachment://" this.fileName
        this.contentType := this.isBitmap ? "image/png" : AttachmentBuilder.MimeType(this.fileName)
    }

    static MimeType(path) {
        f := FileOpen(path, "r")
        if !IsObject(f)
            throw Error("AttachmentBuilder: Could not open file to detect MIME type.", , path)

        n := f.ReadUInt()
        f.Close()

        return (n = 0x474E5089)     ? "image/png"
             : (n = 0x38464947)     ? "image/gif"
             : (n & 0xFFFF0000 = 0x4D42)  ? "image/bmp"
             : (n & 0xFFFF0000 = 0xD8FF)  ? "image/jpeg"
             : (n & 0xFFFF = 0x4949)      ? "image/tiff"
             : (n & 0xFFFF = 0x4D4D)      ? "image/tiff"
             : (n = 0x25504446)     ? "application/pdf"
             : (n = 0x504B0304)     ? "application/zip"
             : (n = 0x52494646)     ? "audio/wav"
             : (n = 0x7F454C46)     ? "application/x-elf"
             : (n = 0x464C5601)     ? "video/x-flv"
             : (n = 0x000001BA)     ? "video/mpeg"
             : (n = 0x000001B3)     ? "video/mpeg"
             : (n & 0xFFFF0000 = 0xFFFB)  ? "audio/mp3"
             : (n = 0x89504E47)     ? "image/x-icon"
             : "application/octet-stream"
    }
}
