# Export Plugin
module.exports = (BasePlugin) ->
	# Define Relations Plugin
	class TaxonomyPlugin extends BasePlugin
		# Plugin Name
		name: 'taxonomy'

		# Parsing all files has finished
		parseAfter: (opts,next) ->
			# Prepare
			docpad = @docpad
			documents = docpad.getCollection @config.collectionName or 'documents'
			vocabularies = @config.vocabularies ? ['tags']

			# Log start
			docpad.log 'debug', 'Generating taxonomy'
			startDate = new Date()

			# Cycle through all vocabularies
			vocabularies.forEach (vocabulary) ->
				# Prepare
				vocabularyDocuments = docpad.getCollection vocabulary

				# Cycle through all vocabulary documents
				vocabularyDocuments.forEach (document) ->

					# Create a live child collection of the related documents
					query = { id: $ne: document.id }
					query[vocabulary] = { $in: document.get(vocabulary) or [] }
					document.relatedDocuments = documents.findAll(query).live true

			# All done, log end
			seconds = (new Date() - startDate) / 1000
			docpad.log 'debug', require('util').format("Generated taxonomy in %s", seconds)
			next()

		# Render Before
		renderBefore: (opts,next) ->
			# Prepare
			vocabularies = @config.vocabularies ? ['tags']

			# Cycle through all vocabularies
			vocabularies.forEach (vocabulary) ->
				# Prepare
				vocabularyDocuments = docpad.getCollection vocabulary

				# Cycle through all vocabulary documents
				vocabularyDocuments.forEach (document) ->
					relatedDocumentsArray = document.relatedDocuments?.toJSON() or []
					document.set(relatedDocuments: relatedDocumentsArray)

			# All done
			next()