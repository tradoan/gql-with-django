import graphene
from blogsite.types import AuthorType, PostType
from blog.models import Author, Post


class Query(graphene.ObjectType):
    feed = graphene.List(PostType)
    post = graphene.Field(PostType, postId=graphene.String())
    all_authors = graphene.List(AuthorType)
    author = graphene.Field(AuthorType, authorId=graphene.String())

    # resolver for feed field
    def resolve_feed(parent, info):
        return Post.objects.all().order_by('-created_at')

    # resolver for post field
    def resolve_post(parent, info, postId):
        return Post.objects.get(id=postId)

    # resolver for all_authors field
    def resolve_all_authors(parent, info):
        return Author.objects.all()

    # resolver for author field
    def resolve_author(parent, info, authorId):
        return Author.objects.get(id=authorId)
    