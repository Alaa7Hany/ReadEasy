# ReadEasy E-Reader App

ReadEasy is a lightweight, performant, and highly customizable e-reading application built with Flutter. It focuses on providing a seamless and comfortable reading experience by intelligently paginating text content to fit any screen size perfectly.

---

## ✨ Key Features

* **📚 Dynamic Text Pagination:** An advanced algorithm that accurately calculates page breaks for `.txt` files, ensuring no text is ever cut off, regardless of screen size or font settings.
* **🎨 Customizable Reading Experience:** Easily adjust font size and switch between multiple background colors (e.g., Cream, White) to reduce eye strain.
* **⚡️ High-Performance Caching:** Intelligently caches pre-calculated page maps. Once a book is prepared for a specific device and font size, it loads instantly on subsequent reads.
* **📱 Fully Responsive UI:** The reading interface is built to be fully responsive, providing an optimal layout on phones, tablets, and other screen sizes.
* **📄 Clean & Decoupled Architecture:** The app follows a clean architecture using Bloc for state management, separating UI, logic, and data layers for better maintainability.
* ** animating page transitions:** that simulate the natural turning of a page in a physical book.

---

## 🚀 Technical Overview

The core challenge in any e-reader is efficiently paginating a large body of text to fit a screen of a specific size. ReadEasy solves this with a robust and performant approach:

1.  **Text Chunking:** Instead of loading the entire book into a `TextPainter`, the repository reads the book in small, manageable chunks (e.g., 2000 characters). This keeps the UI responsive and avoids performance bottlenecks.

2.  **Precise Calculation:** It uses Flutter's `TextPainter` to measure exactly how much text from each chunk can fit within the calculated screen bounds (the `pageSize`).

3.  **Page Map Generation:** The app generates a `List<int>` known as a "page map." This list simply stores the starting character index for each page. For example, `[0, 2450, 4890, ...]`. This map is extremely lightweight and efficient.

4.  **Smart Caching:** The generated page map is cached using a unique key that combines the **book ID, font size, and the screen dimensions**. This ensures that the app only re-calculates pages when necessary (e.g., when the user changes a setting or rotates the device).

This architecture ensures that the initial book preparation is fast and that subsequent reading sessions are instantaneous.

---


## 🔮 Future Work

This project has a solid foundation that can be extended with many exciting features:

* **Book Library:** A main screen to display a grid of available books.
* **Dark Mode:** A theme for comfortable reading in low-light environments.
* **Bookmarks:** The ability to save and jump back to specific pages.
* **Support for More Formats:** Add support for ePub or other popular e-book formats.
