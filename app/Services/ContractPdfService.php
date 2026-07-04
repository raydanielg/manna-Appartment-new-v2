<?php

namespace App\Services;

use App\Models\Contract;
use Illuminate\Support\Facades\Storage;

class ContractPdfService
{
    public function generate(Contract $contract): string
    {
        // TODO: integrate barryvdh/laravel-dompdf
        $path = 'contracts/' . $contract->id . '.pdf';
        Storage::disk('public')->put($path, 'PDF placeholder');
        $contract->update(['pdf_url' => Storage::disk('public')->url($path)]);
        return Storage::disk('public')->url($path);
    }
}
