# server.py
import os
from flask import Flask, request, jsonify
from google.cloud import vision
import spotipy
from spotipy.oauth2 import SpotifyClientCredentials
import pybase64
import json

app = Flask(__name__)

# Set the path to your Google Cloud credentials file
os.environ["GOOGLE_APPLICATION_CREDENTIALS"] = "lib/compact-pier-402315-02e193368305.json"

# Initialize Google Cloud Vision and Spotify API clients
vision_client = vision.ImageAnnotatorClient()
SPOTIPY_CLIENT_ID = 'bf05e37b54b84123a3752f4803159ab2'
SPOTIPY_CLIENT_SECRET = '49e2e5cc84bd442781c2c3b8f1322d64'
sp = spotipy.Spotify(auth_manager=SpotifyClientCredentials(client_id=SPOTIPY_CLIENT_ID, client_secret=SPOTIPY_CLIENT_SECRET))

@app.route('/upload', methods=['POST'])
def upload_image():
    # Receive the uploaded image from the Flutter app
    image = json.loads(request.data)['image']
    # return jsonify({'image':image})
    if image:
        # Save the uploaded image temporarily
        image_path = 'temp_image.jpg'
        
        with open(image_path,"wb") as f:
            f.write(pybase64.b64decode(image))
        
        keywords = extract_keywords(image_path)
        recommendations = get_recommendations(keywords)
        return jsonify(recommendations)
        # results = sp.search(q='Screenshot', limit=20)
        # return jsonify(results)
    else:
        return jsonify({'error': 'No image received'})

def detect_labels(image_path):
    client = vision.ImageAnnotatorClient()
    with open(image_path, 'rb') as image_file:
        content = image_file.read()
    
    response = client.label_detection(image=vision.Image(content=content))
    labels = [label.description for label in response.label_annotations]
    
    return labels

def detect_objects(image_path):
    client = vision.ImageAnnotatorClient()
    with open(image_path, 'rb') as image_file:
        content = image_file.read()
    
    response = client.object_localization(image=vision.Image(content=content))
    objects = [obj.name for obj in response.localized_object_annotations]
    
    return objects
def detect_text(image_path):
    client = vision.ImageAnnotatorClient()
    with open(image_path, 'rb') as image_file:
        content = image_file.read()
    
    response = client.text_detection(image=vision.Image(content=content))
    texts = [text.description for text in response.text_annotations]
    
    return texts

def extract_keywords(image_path):
    labels = detect_labels(image_path)
    objects = detect_objects(image_path)
    texts = detect_text(image_path)
    keywords = texts + objects + labels
    return keywords

def get_recommendations(keywords):
     # Search for tracks based on keywords
    track_results = []
    for keyword in keywords:
        if len(keyword) < 50:
            results = sp.search(q=keyword, type='track', limit=5)
            tracks = results['tracks']['items']
            track_results.extend(tracks)
    
    # Extract relevant information for recommendations
    recommendations = []
    for track in track_results:
        recommendation_info = {
            'name': track['name'],
            'artists': ', '.join([artist['name'] for artist in track['artists']]),
            'album': track['album']['name'],
            'preview_url': track['preview_url']
        }
        recommendations.append(recommendation_info)
    
    return recommendations

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=5000)
