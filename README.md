# Browser Plugin to Detect Phishing Attacks Using LLMs

## Objective
To simulate a browser-based phishing detection system using Large Language Models (LLMs) that analyse webpage content and URL structures for contextual phishing cues in real-time.

## Simulation Type
Cybersecurity Simulation / Browser Extension AI-based Detection

## Types of Dataset
1. Phishing and legitimate URLs
2. webpage text content
3. HTML structures
4. NLP-labelled datasets

## Possible Sources for Dataset
1. PhishTank
2. OpenPhish
3. Kaggle phishing datasets
4. UCI repository
5. WebShrinker

## Dataset URLs
1. https://www.kaggle.com/datasets/sid321axn/phishing-site-url-dataset
2. https://openphish.com
3. https://www.phishtank.com
4. https://www.webshrinker.com
5. https://archive.ics.uci.edu/ml/datasets/phishing+websites

## Setup Instructions
1. 1. Collect and preprocess URL + webpage content datasets
2. 2. Fine-tune or prompt a Large Language Model (e.g., GPT-3.5, LLaMA) to classify phishing vs legitimate
3. 3. Build a browser plugin (Chrome/Firefox) using JavaScript
4. 4. Plugin reads DOM and page URL
5. 5. Sends context to LLM or pre-trained phishing classifier
6. 6. Local cache stores results to reduce API calls
7. 7. Display warning badges/popups on detection
8. 8. Evaluate performance using confusion matrix and accuracy scores

## Implementation Guide
1. 1. Real-time phishing detection pop-up
2. 2. Highlighted risky links on pages
3. 3. Detection score or classification label
4. 4. Local cache of recent URLs
5. 5. Plugin settings panel
6. 6. Detection metrics (Accuracy, Precision, Recall, F1-score)

## Expected Output(s)
1. A plugin-based intelligent phishing detector using LLMs; edge-based threat detection simulation that adapts to contextual semantics of web content; LLM-augmented real-time analysis and caching strategy

## Background Studies
### Cybersecurity Threat Simulation
Phishing attacks are a prevalent form of cybercrime where attackers impersonate legitimate entities to deceive individuals into disclosing sensitive information such as usernames, passwords, and credit card details. These attacks exploit human trust and technological vulnerabilities, making them a significant threat to both individuals and organizations.

One of the defining features of phishing attacks is URL obfuscation. Attackers manipulate website links to resemble legitimate URLs, often using techniques like replacing characters (e.g., using “rn” instead of “m”), adding subdomains (e.g., paypal.secure-login.com), or employing link shorteners to hide the final destination. This tactic misleads users into clicking on harmful links, believing they are interacting with a trusted website.

Another major component is social engineering content. Phishing messages often leverage fear, urgency, or curiosity to trick users into taking immediate action—such as clicking a link or downloading an attachment. For example, emails might claim account suspension, tax penalties, or suspicious logins to prompt hasty decisions. These messages are crafted to look authentic, mimicking logos, language styles, and formats of legitimate institutions.

Due to the evolving sophistication of phishing techniques, detecting and mitigating such attacks has become increasingly challenging, necessitating advanced tools and intelligent systems capable of analyzing URLs and textual content dynamically.

### Large Language Models
With the increasing sophistication of phishing attacks, traditional detection methods—based on keyword matching or static rules—often fall short. This gap has led to the integration of artificial intelligence, particularly Large Language Models (LLMs), into cybersecurity solutions.

LLMs like GPT and BERT are trained on vast amounts of text data, enabling them to understand context, intent, and semantics of human language. In phishing detection, this capability is leveraged to analyze the textual content of webpages to determine if the language and tone align with legitimate usage or mimic phishing characteristics. For example, LLMs can detect subtle signs of social engineering, such as manipulative urgency or requests for sensitive information.

Unlike traditional systems that rely on surface-level features, LLMs perform deep semantic analysis, interpreting the meaning behind text regardless of exact word usage. This makes them effective at detecting phishing pages that use cleverly disguised language or unfamiliar vocabulary to evade detection.

By applying LLMs to webpage content, cybersecurity systems can flag suspicious semantic patterns, assess trustworthiness, and even provide context-aware warnings to users. This AI-driven approach enhances detection accuracy and adaptability in a threat landscape that is constantly evolving.

### Browser Plugin Architecture
Browser extensions enhance browser capabilities using a combination of scripts and user interface components. The core components include background scripts, content scripts, and UI elements.

**Background scripts**: run in the background and manage tasks like event handling, data storage, and communication with servers or other scripts. They are persistent and serve as the control center of the extension.

**Content scripts**: are injected into web pages and can read, modify, or interact with the page’s content. They operate in a sandboxed environment and cannot directly access all browser APIs, so they communicate with background scripts using message passing.

**UI interaction**: includes elements like popups, browser action icons, and options pages. These provide users with interfaces to view alerts, toggle settings, or perform actions. All parts of the extension work together to deliver functionality while respecting browser security policies.

This modular architecture makes extensions powerful tools for tasks such as phishing detection, where real-time analysis and interaction are required.


### Local Caching
Local storage is a web storage mechanism that allows browser extensions and web apps to store data directly on the user's device. It is key to improving performance by reducing the need for repeated computations or network requests.

For phishing detection systems, caching previously analyzed URLs or webpage data in local storage helps avoid redundant scans, speeding up analysis and saving processing time. It also ensures faster load times and allows the extension to work offline or in low-network conditions.

Unlike session storage, local storage persists across browser sessions, making it ideal for storing frequently accessed data like detection results, user preferences, or a list of flagged domains.

This optimization approach enhances user experience while reducing the load on remote servers or APIs.

### Model Evaluation
To evaluate the effectiveness of a phishing detection model, key performance metrics are used:

**Confusion Matrix**: A table showing true positives (TP), false positives (FP), true negatives (TN), and false negatives (FN), helping visualize model accuracy.

**Precision**: Measures how many predicted phishing URLs are actually phishing (TP / (TP + FP)), indicating reliability.

**Recall**: Measures how many actual phishing URLs were correctly identified (TP / (TP + FN)), indicating coverage.

**AUC (Area Under the ROC Curve)**: Reflects the model’s ability to distinguish between phishing and non-phishing instances. A higher AUC means better performance.

Together, these metrics help ensure the model detects threats accurately while minimizing false alarms.

### Human-Computer Interaction
User alerts and controls in browser extensions are crucial for informing and protecting users from threats like phishing. Effective design focuses on clarity, urgency, and user control.

Alerts should be visually distinct, using colors (e.g., red for danger) and icons to indicate risk. Messages must be concise, explain the threat clearly, and suggest safe actions. Popups or in-page warnings are common formats.

User controls—like allow/block buttons, toggles, or settings pages—let users make informed decisions and customize behavior. Good design avoids overwhelming users while still offering necessary flexibility and transparency.

These UI elements play a key role in ensuring the extension communicates effectively and builds trust.

### Heuristics vs AI
Traditional blacklist methods rely on a database of known malicious URLs. When a user visits a site, it is checked against the list. While fast and simple, this method is ineffective against new or obfuscated phishing sites and requires constant updates.

In contrast, semantic detection uses AI models—like LLMs—to analyze the meaning and intent of webpage content, structure, and behavior. It can detect previously unseen phishing tactics by understanding suspicious language, requests, or patterns.

Semantic methods are more adaptive and accurate, though often computationally heavier. Combining both approaches can enhance coverage and speed.

### Edge Security Deployment
Running AI-based security (like phishing detection) on the client side means analysis happens directly in the user's browser or device, rather than sending data to a central server. This approach improves privacy, reduces latency, and allows real-time protection even offline.

It also reduces server load and bandwidth use, but requires optimized, lightweight models due to limited local resources. Client-level AI enhances responsiveness and avoids delays or exposure from remote communication, making it ideal for security-focused browser extensions.

However, challenges include update management and ensuring consistent model performance across devices.
