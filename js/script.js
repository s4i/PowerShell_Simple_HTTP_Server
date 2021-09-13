const ch_url = 'http://127.0.0.1:5000/api/ch/';
const wh_url = 'http://127.0.0.1:5000/api/wh/';
const title_url = {
	"Story1": ch_url,
	"Story2": wh_url,
};
const command_url = {
	"init": 'init',
	"search": 'search',
	"register": 'regiseter',
};
var GLOBAL_TABLE = null;

// クラス定義
// コンストラクタ
let Base = function (api_url) {
	this._url = api_url;
};

Base.prototype.getUrl = function () {
	return this._url;
};

// インターフェース
Base.prototype.createTable = function () {
	// 実装を強制
	throw new Error('Not Implemented');
};

// 継承
let inherits = function (child, parent) {
	Object.setPrototypeOf(child.prototype, parent.prototype);
};

// 子クラス1
let CH = function (api_url) {
	Base.call(this, api_url);
};
// 継承実行
inherits(CH, Base);

CH.prototype.createTable = function (command) {
	// ダウンロード
	jSuites.ajax({
		url: this.getUrl(),
		method: 'POST',
		data: null,
		dataType: 'json',
		success: function (result) {
			let response = result;
			if (command === 'init') {
				createTable(response);
			} else {
				updateTable(response);
			}
		},
		error: function (err, result) {
			alert('通信に失敗しました。');
		},
	});

	let createTable = function (response) {
		let columns = response.columns ? response.columns : {};
		let nestedHeaders = response.nestedHeaders !== undefined ? response.nestedHeaders : {};
		GLOBAL_TABLE = jspreadsheet(document.getElementById('spreadsheet'), {
			data: Array(100),
			tableOverflow: true,
			tableHeight: '70vh',
			columnDrag: true,
			columns: columns,
			nestedHeaders: nestedHeaders,
			allowComments: true,
			contextMenu: function (obj, x, y, e) {
				// 右クリックの定義の上書き
				var items = [];
				// Save
				if (obj.options.allowExport) {
					items.push({
						title: obj.options.text.saveAs,
						// shortcut: 'Ctrl + S',
					});
				}
				return items;
			}
		});
	};

	let updateTable = function (response) {
		let data = {};
		console.log(response);
		if (response.data === undefined) {
			alert('keyが存在しない');
			return;
		} else {
			if (response.data.length <= 100) {
				GLOBAL_TABLE.setData(response.data.concat(Array(100 - response.data.length)));
			}
		}
	};
};

// // 初期表示
window.onload = function () {
	'use strict';
	let page_title = document.getElementById('title').textContent;
	let instance = new CH(title_url[page_title] + command_url.init);
	instance.createTable('init');
};

// 検索ボタン
let search_button = document.querySelector('button[name="search"]');
search_button.addEventListener('click', function () {
	'use strict';
	let page_title = document.getElementById('title').textContent;
	let instance = new CH(title_url[page_title] + command_url.search);
	instance.createTable('search');
});

// 登録ボタン
let register_button = document.querySelector('button[name="register"]');
register_button.addEventListener('click', function () {
	'use strict';
	let page_title = document.getElementById('title').textContent;
	let instance = new CH(title_url[page_title] + command_url.register);
	instance.createTable('register');
});

// 子クラス2
// let WH = function (api_url) {
// 	Base.call(this, api_url);
// };
// inherits(WH, Base);