<?php

namespace App\Services;

use App\Models\Contract;
use Barryvdh\DomPDF\Facade\Pdf;
use Illuminate\Support\Facades\Storage;

class ContractPdfService
{
    public function generate(Contract $contract): string
    {
        $contract->load(['tenant.user', 'unit.property']);
        $signatureBase64 = null;
        if ($contract->signature_path && Storage::disk('public')->exists($contract->signature_path)) {
            $signatureBase64 = 'data:image/png;base64,' . base64_encode(Storage::disk('public')->get($contract->signature_path));
        }

        $pdf = Pdf::loadView('pdf.contract', [
            'contract' => $contract,
            'signatureBase64' => $signatureBase64,
        ]);

        $pdf->setPaper('A4');
        $path = 'contracts/' . $contract->id . '.pdf';
        Storage::disk('public')->put($path, $pdf->output());
        $url = Storage::disk('public')->url($path);
        $contract->update(['pdf_url' => $url]);
        return $url;
    }
}
