import { Injectable } from '@nestjs/common';
import { PDFDocument } from 'pdf-lib';

@Injectable()
export class ImageToPdfService {
  async convertSingleImageToPdf(input: {
    buffer: Buffer;
    mimetype: 'image/jpeg' | 'image/png';
  }): Promise<Buffer> {
    const pdfDoc = await PDFDocument.create();
    const image =
      input.mimetype === 'image/png'
        ? await pdfDoc.embedPng(input.buffer)
        : await pdfDoc.embedJpg(input.buffer);
    const { width, height } = image.scale(1);
    const page = pdfDoc.addPage([width, height]);
    page.drawImage(image, {
      x: 0,
      y: 0,
      width,
      height,
    });
    const bytes = await pdfDoc.save();
    return Buffer.from(bytes);
  }
}
