

curl --request POST \
    --url https://api.climatiq.io/estimate \
    --header "Authorization: Bearer $CLIMATIQ_API_KEY" \
    --data '{
	"emission_factor": {
		"activity_id": "consumer_goods-type_dairy_products",
		"source": "EXIOBASE",
		"region": "AU",
		"year": 2019,
		"source_lca_activity": "unknown",
		"data_version": "^20"
	},
	"parameters": {
		"money": 500,
		"money_unit": "usd"
	}
}'