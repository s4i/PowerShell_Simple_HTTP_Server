const ch_url = 'http://127.0.0.1:5000/api/json1';
const wh_url = 'http://127.0.0.1:5000/api/json2';
const title_url_dict = {
	"Story1": ch_url,
	"Story2": wh_url,
};

// クラス定義
// コンストラクタ
// let Super = function (api_url) {
// 	this.url = api_url;
// };
// Super.prototype.getURL = function () {
// 	return this.url;
// };
// インターフェース
// Super.prototype.createTableData = function () {
// 	throw new Error('Not Implemented');
// };
// 継承
// let inherits = function (child, parent) {
// 	Object.setPrototypeOf(child.prototype, parent.prototype);
// };

// 子クラス1
// let CH = function (api_url) {
// 	Super.call(this, api_url);
// 	this.response = {};
// };
// CH.prototype.setResponse = function (value) {
// 	this.response = value;
// };
// CH.prototype.getResponse = function () {
// 	return this.response;
// };
// inherits(CH, Super);

// CH.prototype.createTableData = function () {
// };

let getJson = function (url) {
	'use strict';
	jSuites.ajax({
		// url: this.getURL(),
		url: url,
		method: 'POST',
		dataType: 'json',
		success: function (result) {
			let response = result.data ? result.data : result;
			createTableData(response);
		},
	});

	let createTableData = function (json_dict) {
		if (typeof json_dict === 'undefined' || Object.keys(json_dict).length <= 0) return;

		let data = [
			[json_dict.start, json_dict.end, 'Yes', '2019/02/12'],
			['US', 'Wholemeal', 'Yes', '2019/02/12'],
			['CA;US;UK', 'Breakfast Cereals', 'Yes', '2019/03/01'],
			['CA;BR', 'Grains', 'No', '2018/11/10'],
			['BR', 'Pasta', 'Yes', '2019/01/12'],
			[], [], [], [], [], [], [], [], [], [],
			[], [], [], [], [], [], [], [], [], [],
			[], [], [], [], [], [], [], [], [], [],
			[], [], [], [], [], [], [], [], [], [],
			[], [], [], [], [], [], [], [], [], [],
			[], [], [], [], [], [], [], [], [], [],
			[], [], [], [], [], [], [], [], [], [],
		];

		jspreadsheet(document.getElementById('spreadsheet'), {
			data: data,
			tableOverflow: true,
			tableHeight: '70vh',
			columns: [{
					type: 'autocomplete',
					title: 'Country',
					width: '300',
				},
				{
					type: 'dropdown',
					title: 'Food',
					width: '150',
					source: ['Apples', 'Bananas', 'Carrots', 'Oranges', 'Cheese']
				},
				{
					type: 'checkbox',
					title: 'Stock',
					width: '100'
				},
				{
					type: 'text',
					title: 'Date',
					width: '100'
				},
			],
			nestedHeaders: [
				[{
					title: 'Supermarket information',
					colspan: '4',
				}, ],
				[{
						title: 'Location',
						colspan: '1',
					},
					{
						title: ' Other Information',
						colspan: '3'
					}
				],
			],
			columnDrag: true,
		});
	};
};


// 右クリックの定義の上書き
let page_title = document.getElementById('title').textContent;
// let instance = new CH(title_url_dict[page_title]);
getJson(title_url_dict[page_title]);
// createTableData();

// 子クラス2
// let WH = function (api_url) {
// 	Super.call(this, api_url);
// };
// inherits(WH, Super);