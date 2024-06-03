BEGIN{
    TYPE_MARKDOWN = 1
    TYPE_WIKI = 2
    TYPE_OTHER = 3
}

function llmtext_type(){

    # We will finisih it . # We must. # We have not choice.

    # find if there is any wikitext syntax: ^=<...>=$ ==h2== ===h3===

    # find if there is any markdown syntax: #, ##, ###, ####

    # Or It is just a json ?

    # Or It is just a yml ...

    return TYPE_MARKDOWN
}

