<?php

use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return view('welcome');
});

// swagger-ui
Route::get('/swagger', function () {
    return view('swagger');
});