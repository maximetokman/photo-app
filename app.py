from dotenv import load_dotenv
load_dotenv()
from flask import Flask
from flask_restful import Api
from flask import render_template
import os
from models import db, Post, User, Following
from views import bookmarks, comments, followers, following, \
    posts, profile, stories, suggestions, post_likes


app = Flask(__name__)

app.config['SQLALCHEMY_DATABASE_URI'] = os.environ.get('DB_URL')
app.config["SQLALCHEMY_TRACK_MODIFICATIONS"] = False    


db.init_app(app)
api = Api(app)

# set logged in user
with app.app_context():
    app.current_user = User.query.filter_by(id=12).one()


# Initialize routes for all of your API endpoints:
bookmarks.initialize_routes(api)
comments.initialize_routes(api)
followers.initialize_routes(api)
following.initialize_routes(api)
posts.initialize_routes(api)
post_likes.initialize_routes(api)
profile.initialize_routes(api)
stories.initialize_routes(api)
suggestions.initialize_routes(api)

# Server-side template for the homepage:
@app.route('/')
def home():
    # pick posts that the user has made:
    posts = Post.query.filter(Post.user.has(username=app.current_user.username)).limit(8)
    
    # pick the first 5 ppl the user is following:
    following = Following.query.filter_by(user_id=app.current_user.id).limit(5).all()
    
    # pick the first 7 ppl the user is *not following:
    suggestions = Following.query.filter(Following.user_id != app.current_user.id).limit(7).all()
    
    return render_template(
        'index.html', 
        user=app.current_user,
        posts=posts,
        stories=[item.following for item in following],
        suggestions=[rec.following for rec in suggestions]
    )

@app.route('/api')
def api_docs():
    friend = Following.query.filter_by(
        user_id=app.current_user.id).limit(1).one()
    stranger = Following.query.filter(
        Following.user_id !=app.current_user.id).limit(1).one()
    return render_template(
        'api_docs.html', 
        user=app.current_user,
        stranger=stranger.following,
        friend=friend.following
    )



# enables flask app to run using "python3 app.py"
if __name__ == '__main__':
    app.run()
