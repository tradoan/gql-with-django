import graphene
from blogsite.queries import Query
from blogsite.mutations import Mutation

schema = graphene.Schema(query=Query, mutation=Mutation)