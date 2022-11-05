from django.db import models

# Create your models here.
class Author(models.Model):
    name = models.CharField(max_length=100)
    biodata = models.TextField()

    def __str__(sel):
        return self.name


class Post(models.Model):
    title = models.CharField(max_length=100)
    content = models.TextField()
    created_at = models.DateTimeField(auto_now=True)
    author = models.ForeignKey(Author, on_delete=models.CASCADE, related_name="posts")

    def __str__(self):
        return self.title
    