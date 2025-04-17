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
Focus on phishing attacks and their characteristics (URL obfuscation, social engineering content).

### Large Language Models
Applying LLMs for semantic text understanding in webpage content.

### Browser Plugin Architecture
Understanding how extensions work (background scripts, content scripts, UI interaction).

### Local Caching
Using local storage for performance optimisation.

### Model Evaluation
Confusion matrix, precision, recall, and AUC used to quantify security model performance.

### Human-Computer Interaction
Designing user alerts and controls in browser interfaces.

### Heuristics vs AI
Comparison of traditional blacklist methods vs semantic detection.

### Edge Security Deployment
Implementing AI security at client level rather than central server.
