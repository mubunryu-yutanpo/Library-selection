<?php
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider within a group which
| is assigned the "api" middleware group. Enjoy building your API!
|
*/

Route::middleware('api')
    ->prefix('api')
    ->group(function () {
        // OpenAPI Generator が吐いたルート定義を読み込む
        require base_path('app/OpenApiGenerated/routes.php');
    });
